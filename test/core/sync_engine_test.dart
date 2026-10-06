import 'package:dio/dio.dart';
import 'package:eschool_app/core/sync/stores.dart';
import 'package:eschool_app/core/sync/sync_engine.dart';
import 'package:flutter_test/flutter_test.dart';

Response<dynamic> okResponse({dynamic data}) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/x'),
      statusCode: 200,
      data: data,
    );

DioException dioError(int status) => DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: status,
        data: <String, dynamic>{'message': 'err $status'},
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  late InMemoryMutationStore mutations;
  late InMemoryKvStore kv;
  late SyncEngine engine;

  setUp(() {
    mutations = InMemoryMutationStore();
    kv = InMemoryKvStore();
    engine = SyncEngine.instance;
    engine.configureForTest(
      mutations: mutations,
      kv: kv,
      poster: (_, __, ___) async => okResponse(),
      isOnline: () async => true,
    );
  });

  test('backoff grows exponentially and caps at 1 hour', () {
    expect(SyncEngine.backoffForAttempt(0), const Duration(seconds: 5));
    expect(SyncEngine.backoffForAttempt(1), const Duration(seconds: 10));
    expect(SyncEngine.backoffForAttempt(2), const Duration(seconds: 20));
    expect(SyncEngine.backoffForAttempt(100), const Duration(seconds: 3600));
  });

  test('offline postMutation enqueues and throws OfflineQueuedException', () async {
    engine.configureForTest(
      mutations: mutations,
      kv: kv,
      isOnline: () async => false,
    );

    await expectLater(
      engine.postMutation('/chat/conversations/1/send', <String, String>{'body': 'halo'}),
      throwsA(isA<OfflineQueuedException>()),
    );
    expect(await mutations.pendingCount(), 1);
  });

  test('flush replays with the stored Idempotency-Key', () async {
    final List<String> seenKeys = <String>[];
    engine.configureForTest(
      mutations: mutations,
      kv: kv,
      isOnline: () async => false,
      poster: (String path, Map<String, dynamic>? body, String key) async {
        seenKeys.add(key);
        return okResponse();
      },
    );

    await expectLater(
      engine.postMutation('/x', <String, String>{'a': 'b'}),
      throwsA(isA<OfflineQueuedException>()),
    );
    final List<QueuedMutation> due =
        await mutations.dueMutations(now: DateTime.now());
    expect(due, hasLength(1));

    engine.configureForTest(
      mutations: mutations,
      kv: kv,
      isOnline: () async => true,
      poster: (String path, Map<String, dynamic>? body, String key) async {
        seenKeys.add(key);
        return okResponse();
      },
    );
    await engine.flush();

    expect(seenKeys, hasLength(1));
    expect(seenKeys.single, due.single.idempotencyKey);
    expect(await mutations.pendingCount(), 0);
  });

  test('flush dead-letters 4xx but reschedules 5xx', () async {
    engine.configureForTest(
      mutations: mutations,
      kv: kv,
      isOnline: () async => false,
    );
    await expectLater(engine.postMutation('/a', null),
        throwsA(isA<OfflineQueuedException>()));
    await expectLater(engine.postMutation('/b', null),
        throwsA(isA<OfflineQueuedException>()));

    int calls = 0;
    engine.configureForTest(
      mutations: mutations,
      kv: kv,
      isOnline: () async => true,
      poster: (String path, Map<String, dynamic>? body, String key) async {
        calls++;
        if (path == '/a') throw dioError(422);
        throw dioError(500);
      },
    );
    await engine.flush();

    expect(calls, 2);
    expect(await mutations.failedMutations(), hasLength(1));
    expect((await mutations.failedMutations()).single.path, '/a');
    // /b stays pending with attempts=1 and a future retry time.
    expect(await mutations.pendingCount(), 1);
  });

  test('retryFailed re-queues dead letters', () async {
    engine.configureForTest(
      mutations: mutations,
      kv: kv,
      isOnline: () async => false,
    );
    await expectLater(engine.postMutation('/a', null),
        throwsA(isA<OfflineQueuedException>()));

    engine.configureForTest(
      mutations: mutations,
      kv: kv,
      isOnline: () async => true,
      poster: (_, __, ___) async => throw dioError(403),
    );
    await engine.flush();
    expect(await mutations.failedMutations(), hasLength(1));

    engine.configureForTest(
      mutations: mutations,
      kv: kv,
      isOnline: () async => true,
      poster: (_, __, ___) async => okResponse(),
    );
    await engine.retryFailed();
    expect(await mutations.pendingCount(), 0);
    expect(await mutations.failedMutations(), isEmpty);
  });

  test('getCached serves cache offline and refreshes online', () async {
    // Seed cache.
    await kv.write('GET /t', '[{"a":1}]');

    engine.configureForTest(
      mutations: mutations,
      kv: kv,
      isOnline: () async => false,
      poster: (_, __, ___) async => okResponse(),
    );
    final List<Map<String, dynamic>> offline = await engine.getCached<List<Map<String, dynamic>>>(
      cacheKey: 'GET /t',
      ttl: const Duration(minutes: 15),
      network: () async => throw StateError('must not hit network'),
      encode: encodeList,
      decode: decodeList,
    );
    expect(offline.single['a'], 1);

    engine.configureForTest(
      mutations: mutations,
      kv: kv,
      isOnline: () async => true,
    );
    final List<Map<String, dynamic>> fresh = await engine.getCached<List<Map<String, dynamic>>>(
      cacheKey: 'GET /t',
      ttl: const Duration(minutes: 15),
      network: () async => <Map<String, dynamic>>[
        <String, dynamic>{'a': 2}
      ],
      encode: encodeList,
      decode: decodeList,
    );
    expect(fresh.single['a'], 2);
    expect((await kv.read('GET /t'))?.body, '[{"a":2}]');
  });
}
