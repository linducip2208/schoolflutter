import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import 'stores.dart';

/// Offline outbox + sync engine.
///
/// UI → Repository → [SyncEngine.postMutation] → online? API : queue.
/// [flush] replays queued mutations with exponential backoff and the
/// `Idempotency-Key` header so request retries never duplicate server
/// transactions (backend honors `idempotency_key` on sensitive endpoints).
class SyncEngine {
  SyncEngine._();

  static final SyncEngine instance = SyncEngine._();

  MutationStore _mutations = InMemoryMutationStore();
  KvStore _kv = InMemoryKvStore();

  /// POST executor (injectable for tests). Defaults to the shared Dio client.
  Future<Response<dynamic>> Function(
          String path, Map<String, dynamic>? body, String idempotencyKey)
      _poster = (String path, Map<String, dynamic>? body, String key) =>
          ApiClient.dio.post<dynamic>(
            path,
            data: body,
            options: Options(headers: <String, String>{'Idempotency-Key': key}),
          );

  /// Online probe (injectable for tests).
  Future<bool> Function() _isOnline = () async {
    final List<ConnectivityResult> r = await Connectivity().checkConnectivity();
    return !r.contains(ConnectivityResult.none);
  };

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _flushing = false;
  bool _started = false;

  final ValueNotifier<int> pendingCount = ValueNotifier<int>(0);

  /// Production wiring with drift-backed stores.
  void configure({required MutationStore mutations, required KvStore kv}) {
    _mutations = mutations;
    _kv = kv;
  }

  @visibleForTesting
  void configureForTest({
    required MutationStore mutations,
    required KvStore kv,
    Future<Response<dynamic>> Function(
            String path, Map<String, dynamic>? body, String idempotencyKey)?
        poster,
    Future<bool> Function()? isOnline,
  }) {
    _mutations = mutations;
    _kv = kv;
    if (poster != null) _poster = poster;
    if (isOnline != null) _isOnline = isOnline;
  }

  KvStore get kv => _kv;
  MutationStore get mutations => _mutations;

  static const int maxAttempts = 8;

  /// Exponential backoff: 5s, 10s, 20s, … capped at 1 hour.
  static Duration backoffForAttempt(int attempts) {
    int seconds = 5 * (1 << (attempts < 10 ? attempts : 10));
    if (seconds > 3600) seconds = 3600;
    return Duration(seconds: seconds);
  }

  Future<void> start() async {
    if (_started) return;
    _started = true;
    await _refreshPendingCount();
    _connectivitySub = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> r) async {
      if (!r.contains(ConnectivityResult.none)) {
        await flush();
      }
    });
    // Opportunistic flush on start (e.g. after app boot with backlog).
    await flush();
  }

  Future<void> stop() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    _started = false;
  }

  /// Clears read cache + mutation outbox (logout/session-expiry).
  /// Prevents the next user on a shared device from seeing the
  /// previous user's cached data or replaying their mutations.
  /// Best-effort: never throws (logout must not fail on storage).
  Future<void> clearLocal() async {
    try {
      await _kv.clear();
    } catch (_) {}
    try {
      await _mutations.clear();
    } catch (_) {}
    try {
      pendingCount.value = 0;
    } catch (_) {}
  }

  /// POST with offline fallback. Returns the server response when online,
  /// otherwise persists to the outbox and throws [OfflineQueuedException].
  ///
  /// The idempotency key is minted BEFORE the first attempt and reused for
  /// the queued replay, so a manual retry after a lost response cannot
  /// create a duplicate server-side (backend dedups on the key).
  Future<Response<dynamic>> postMutation(
      String path, Map<String, dynamic>? body) async {
    final String key = _newKey();
    if (await _isOnline()) {
      try {
        return await _poster(path, body, key);
      } on DioException catch (e) {
        if (_isOfflineError(e)) {
          final QueuedMutation m = await _mutations.enqueue(
              method: 'POST', path: path, body: body, idempotencyKey: key);
          await _refreshPendingCount();
          throw OfflineQueuedException(m.id);
        }
        rethrow;
      }
    }
    final QueuedMutation m = await _mutations.enqueue(
        method: 'POST', path: path, body: body, idempotencyKey: key);
    await _refreshPendingCount();
    throw OfflineQueuedException(m.id);
  }

  static bool _isOfflineError(DioException e) =>
      e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.receiveTimeout;

  /// Replay due mutations. Safe to call anytime; no-op when offline.
  Future<void> flush() async {
    if (_flushing) return;
    if (!await _isOnline()) return;
    _flushing = true;
    try {
      final DateTime now = DateTime.now();
      final List<QueuedMutation> due = await _mutations.dueMutations(now: now);
      for (final QueuedMutation m in due) {
        try {
          await _poster(m.path, m.bodyJson, m.idempotencyKey);
          await _mutations.markDone(m.id);
        } on DioException catch (e) {
          if (e.response != null && (e.response!.statusCode ?? 500) < 500) {
            // 4xx = server rejected it; retrying won't help → dead-letter.
            await _mutations.markFailed(m.id,
                error: 'HTTP ${e.response!.statusCode}');
            continue;
          }
          final int attempts = m.attempts + 1;
          if (attempts >= maxAttempts) {
            await _mutations.markFailed(m.id,
                error: e.message ?? 'sync failed');
          } else {
            await _mutations.markAttempt(
              m.id,
              attempts: attempts,
              nextRetryAt: DateTime.now().add(backoffForAttempt(attempts)),
              error: e.message ?? 'sync failed',
            );
          }
        }
      }
    } finally {
      _flushing = false;
      await _refreshPendingCount();
    }
  }

  Future<void> retryFailed() async {
    await _mutations.retryFailed();
    await _refreshPendingCount();
    await flush();
  }

  /// Batch replay for attendance/mark mutations via backend POST /sync/batch.
  ///
  /// Backend accepts max 200 records {type: attendance|mark, local_id, ...},
  /// returns 200 (all ok) or 207 (partial). Individual non-batch mutations
  /// continue via [flush]. Safe to call anytime; no-op when offline.
  Future<Map<String, dynamic>> flushBatch({
    required String type,
    required List<Map<String, dynamic>> records,
  }) async {
    assert(
      type == 'attendance' || type == 'mark',
      'sync/batch only supports attendance|mark',
    );
    assert(records.length <= 200, 'sync/batch max 200 records');
    final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
      ApiEndpoints.syncBatch,
      data: <String, dynamic>{
        'type': type,
        'records': records,
      },
    );
    final dynamic data = r.data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{'success': true};
  }

  Future<void> _refreshPendingCount() async {
    try {
      pendingCount.value = await _mutations.pendingCount();
    } catch (_) {
      // store unavailable (e.g. before configure) — keep last value.
    }
  }

  /// Cache-then-network GET helper. Returns cached body when fresh or when
  /// offline; throws the network error when nothing cached.
  Future<T> getCached<T>({
    required String cacheKey,
    required Duration ttl,
    required Future<T> Function() network,
    required String Function(T value) encode,
    required T Function(String raw) decode,
  }) async {
    final CachedEntry? cached = await _kv.read(cacheKey);
    final bool online = await _isOnline();
    if (!online && cached != null) {
      return decode(cached.body);
    }
    try {
      final T value = await network();
      await _kv.write(cacheKey, encode(value));
      return value;
    } catch (_) {
      if (cached != null) return decode(cached.body);
      rethrow;
    }
  }
}

/// Thrown when a mutation was persisted to the offline outbox.
/// UI should inform the user it will sync automatically.
class OfflineQueuedException implements Exception {
  OfflineQueuedException(this.queueId);
  final int queueId;

  String get message => 'Tersimpan offline, akan dikirim otomatis saat online.';
  @override
  String toString() => message;
}

String _newKey() =>
    '${DateTime.now().microsecondsSinceEpoch}-${(identityHashCode(Object()) % 0xffffff).toRadixString(16)}';

/// Cache-key builder for GET endpoints.
String cacheKey(String path, [Map<String, dynamic>? query]) {
  if (query == null || query.isEmpty) return 'GET $path';
  final List<String> parts = query.entries
      .map((MapEntry<String, dynamic> e) => '${e.key}=${e.value}')
      .toList()
    ..sort();
  return 'GET $path?${parts.join('&')}';
}

/// JSON list codec for [SyncEngine.getCached].
String encodeList(List<Map<String, dynamic>> items) => json.encode(items);
List<Map<String, dynamic>> decodeList(String raw) =>
    (json.decode(raw) as List<dynamic>)
        .map((dynamic e) => Map<String, dynamic>.from(e as Map))
        .toList();
