import 'dart:convert';

import 'package:drift/drift.dart';

import 'app_database.dart';

/// Cached GET response.
class CachedEntry {
  CachedEntry({required this.body, required this.updatedAt});
  final String body;
  final DateTime updatedAt;
}

/// Queued mutation row.
class QueuedMutation {
  QueuedMutation({
    required this.id,
    required this.method,
    required this.path,
    required this.body,
    required this.idempotencyKey,
    required this.attempts,
    required this.nextRetryAt,
    required this.lastError,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String method;
  final String path;
  final String? body;
  final String idempotencyKey;
  final int attempts;
  final DateTime? nextRetryAt;
  final String? lastError;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic>? get bodyJson =>
      body == null ? null : json.decode(body!) as Map<String, dynamic>;
}

abstract class KvStore {
  Future<CachedEntry?> read(String key);
  Future<void> write(String key, String body);
  Future<void> invalidate(String key);

  /// Clears all cached rows (called on logout/session-expiry so the next
  /// user on a shared device never sees the previous user's data).
  Future<void> clear();
}

abstract class MutationStore {
  Future<QueuedMutation> enqueue({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    String? idempotencyKey,
  });
  Future<List<QueuedMutation>> dueMutations(
      {required DateTime now, int limit = 25});
  Future<void> markDone(int id);
  Future<void> markAttempt(int id,
      {required int attempts,
      required DateTime nextRetryAt,
      required String error});
  Future<void> markFailed(int id, {required String error});
  Future<void> retryFailed();
  Future<int> pendingCount();
  Future<List<QueuedMutation>> failedMutations();
  Future<void> delete(int id);

  /// Clears the whole outbox (logout/session-expiry).
  Future<void> clear();
}

// ── Drift implementations (production) ──────────────────────────────

class DriftKvStore implements KvStore {
  DriftKvStore(this.db);
  final AppDatabase db;

  @override
  Future<CachedEntry?> read(String key) async {
    final KvCacheData? row = await (db.select(db.kvCache)
          ..where((KvCache t) => t.key.equals(key)))
        .getSingleOrNull();
    if (row == null) return null;
    return CachedEntry(body: row.body, updatedAt: row.updatedAt);
  }

  @override
  Future<void> write(String key, String body) async {
    await db.into(db.kvCache).insertOnConflictUpdate(
          KvCacheCompanion.insert(
              key: key, body: body, updatedAt: DateTime.now()),
        );
  }

  @override
  Future<void> invalidate(String key) async {
    await (db.delete(db.kvCache)..where((KvCache t) => t.key.equals(key))).go();
  }

  @override
  Future<void> clear() async {
    await db.delete(db.kvCache).go();
  }
}

class DriftMutationStore implements MutationStore {
  DriftMutationStore(this.db);
  final AppDatabase db;

  QueuedMutation _map(MutationQueueData r) => QueuedMutation(
        id: r.id,
        method: r.method,
        path: r.path,
        body: r.body,
        idempotencyKey: r.idempotencyKey,
        attempts: r.attempts,
        nextRetryAt: r.nextRetryAt,
        lastError: r.lastError,
        status: r.status,
        createdAt: r.createdAt,
      );

  @override
  Future<QueuedMutation> enqueue({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    String? idempotencyKey,
  }) async {
    final String key = idempotencyKey ?? _newKey();
    final int id = await db.into(db.mutationQueue).insert(
          MutationQueueCompanion.insert(
            method: method,
            path: path,
            body: Value<String?>(body == null ? null : json.encode(body)),
            idempotencyKey: key,
          ),
        );
    final MutationQueueData row = await (db.select(db.mutationQueue)
          ..where((MutationQueue t) => t.id.equals(id)))
        .getSingle();
    return _map(row);
  }

  @override
  Future<List<QueuedMutation>> dueMutations(
      {required DateTime now, int limit = 25}) async {
    final List<MutationQueueData> rows = await (db.select(db.mutationQueue)
          ..where((MutationQueue t) =>
              t.status.equals('pending') &
              (t.nextRetryAt.isNull() |
                  t.nextRetryAt.isSmallerOrEqualValue(now)))
          ..orderBy(<OrderClauseGenerator<MutationQueue>>[
            (MutationQueue t) => OrderingTerm.asc(t.id)
          ])
          ..limit(limit))
        .get();
    return rows.map(_map).toList();
  }

  @override
  Future<void> markDone(int id) async {
    await (db.delete(db.mutationQueue)
          ..where((MutationQueue t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<void> markAttempt(int id,
      {required int attempts,
      required DateTime nextRetryAt,
      required String error}) async {
    await (db.update(db.mutationQueue)
          ..where((MutationQueue t) => t.id.equals(id)))
        .write(
      MutationQueueCompanion(
        attempts: Value<int>(attempts),
        nextRetryAt: Value<DateTime?>(nextRetryAt),
        lastError: Value<String?>(error),
      ),
    );
  }

  @override
  Future<void> markFailed(int id, {required String error}) async {
    await (db.update(db.mutationQueue)
          ..where((MutationQueue t) => t.id.equals(id)))
        .write(
      MutationQueueCompanion(
          status: const Value<String>('failed'),
          lastError: Value<String?>(error)),
    );
  }

  @override
  Future<void> retryFailed() async {
    await (db.update(db.mutationQueue)
          ..where((MutationQueue t) => t.status.equals('failed')))
        .write(
      MutationQueueCompanion(
        status: const Value<String>('pending'),
        attempts: const Value<int>(0),
        nextRetryAt: Value<DateTime?>(DateTime.now()),
        lastError: const Value<String?>(null),
      ),
    );
  }

  @override
  Future<int> pendingCount() async {
    final int? count = await (db.selectOnly(db.mutationQueue)
          ..addColumns(<Expression<int>>[db.mutationQueue.id.count()])
          ..where(db.mutationQueue.status.equals('pending')))
        .map((TypedResult r) => r.read(db.mutationQueue.id.count()))
        .getSingleOrNull();
    return count ?? 0;
  }

  @override
  Future<List<QueuedMutation>> failedMutations() async {
    final List<MutationQueueData> rows = await (db.select(db.mutationQueue)
          ..where((MutationQueue t) => t.status.equals('failed'))
          ..orderBy(<OrderClauseGenerator<MutationQueue>>[
            (MutationQueue t) => OrderingTerm.desc(t.id)
          ]))
        .get();
    return rows.map(_map).toList();
  }

  @override
  Future<void> delete(int id) => markDone(id);

  @override
  Future<void> clear() async {
    await db.delete(db.mutationQueue).go();
  }
}

String _newKey() =>
    '${DateTime.now().microsecondsSinceEpoch}-${(identityHashCode(Object()) % 0xffffff).toRadixString(16)}';

// ── In-memory implementations (widget/unit tests) ───────────────────

class InMemoryKvStore implements KvStore {
  final Map<String, CachedEntry> _map = <String, CachedEntry>{};

  @override
  Future<CachedEntry?> read(String key) async => _map[key];

  @override
  Future<void> write(String key, String body) async {
    _map[key] = CachedEntry(body: body, updatedAt: DateTime.now());
  }

  @override
  Future<void> invalidate(String key) async => _map.remove(key);

  @override
  Future<void> clear() async => _map.clear();
}

class InMemoryMutationStore implements MutationStore {
  final List<QueuedMutation> _rows = <QueuedMutation>[];
  int _seq = 0;

  @override
  Future<QueuedMutation> enqueue(
      {required String method,
      required String path,
      Map<String, dynamic>? body,
      String? idempotencyKey}) async {
    final QueuedMutation m = QueuedMutation(
      id: ++_seq,
      method: method,
      path: path,
      body: body == null ? null : json.encode(body),
      idempotencyKey: idempotencyKey ?? _newKey(),
      attempts: 0,
      nextRetryAt: null,
      lastError: null,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    _rows.add(m);
    return m;
  }

  @override
  Future<List<QueuedMutation>> dueMutations(
      {required DateTime now, int limit = 25}) async {
    final List<QueuedMutation> due = _rows
        .where((QueuedMutation m) =>
            m.status == 'pending' &&
            (m.nextRetryAt == null || !m.nextRetryAt!.isAfter(now)))
        .toList()
      ..sort((QueuedMutation a, QueuedMutation b) => a.id.compareTo(b.id));
    return due.take(limit).toList();
  }

  QueuedMutation _replace(QueuedMutation m) {
    final int i = _rows.indexWhere((QueuedMutation e) => e.id == m.id);
    _rows[i] = m;
    return m;
  }

  @override
  Future<void> markDone(int id) async =>
      _rows.removeWhere((QueuedMutation e) => e.id == id);

  @override
  Future<void> markAttempt(int id,
      {required int attempts,
      required DateTime nextRetryAt,
      required String error}) async {
    final QueuedMutation m = _rows.firstWhere((QueuedMutation e) => e.id == id);
    _replace(QueuedMutation(
      id: m.id,
      method: m.method,
      path: m.path,
      body: m.body,
      idempotencyKey: m.idempotencyKey,
      attempts: attempts,
      nextRetryAt: nextRetryAt,
      lastError: error,
      status: m.status,
      createdAt: m.createdAt,
    ));
  }

  @override
  Future<void> markFailed(int id, {required String error}) async {
    final QueuedMutation m = _rows.firstWhere((QueuedMutation e) => e.id == id);
    _replace(QueuedMutation(
      id: m.id,
      method: m.method,
      path: m.path,
      body: m.body,
      idempotencyKey: m.idempotencyKey,
      attempts: m.attempts,
      nextRetryAt: m.nextRetryAt,
      lastError: error,
      status: 'failed',
      createdAt: m.createdAt,
    ));
  }

  @override
  Future<void> retryFailed() async {
    for (final QueuedMutation m
        in _rows.where((QueuedMutation e) => e.status == 'failed').toList()) {
      _replace(QueuedMutation(
        id: m.id,
        method: m.method,
        path: m.path,
        body: m.body,
        idempotencyKey: m.idempotencyKey,
        attempts: 0,
        nextRetryAt: DateTime.now(),
        lastError: null,
        status: 'pending',
        createdAt: m.createdAt,
      ));
    }
  }

  @override
  Future<int> pendingCount() async =>
      _rows.where((QueuedMutation e) => e.status == 'pending').length;

  @override
  Future<List<QueuedMutation>> failedMutations() async =>
      _rows.where((QueuedMutation e) => e.status == 'failed').toList();

  @override
  Future<void> delete(int id) => markDone(id);

  @override
  Future<void> clear() async => _rows.clear();
}
