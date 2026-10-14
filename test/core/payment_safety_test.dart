import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eschool_app/core/api/api_client.dart';
import 'package:eschool_app/core/api/api_endpoints.dart';
import 'package:eschool_app/core/error/app_exception.dart';
import 'package:eschool_app/core/storage/app_storage.dart';
import 'package:eschool_app/core/sync/stores.dart';
import 'package:eschool_app/core/sync/sync_engine.dart';
import 'package:eschool_app/features/auth/data/auth_repository.dart';
import 'package:eschool_app/features/fees/data/fees_repository.dart';
import 'package:eschool_app/features/payment/data/payment_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression tests for the payment/idempotency + session audit:
/// - double-tap on manual payment must not record twice (P1);
/// - gateway initiate must carry a caller-provided stable key (P1);
/// - malformed login bodies must raise ServerException, not TypeError (P2);
/// - login as a different user must wipe the offline outbox (P0).
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      handler(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(dynamic data, int code) => ResponseBody.fromString(
      json.encode(data),
      code,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>[Headers.jsonContentType],
      },
    );

void _useDio(Future<ResponseBody> Function(RequestOptions) handler) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://test.invalid/api/v1',
      validateStatus: (int? code) => code != null && code >= 200 && code < 300,
    ),
  );
  dio.httpClientAdapter = _FakeAdapter(handler);
  ApiClient.debugOverrideDio(dio);
}

Map<String, dynamic> _user(int id) => <String, dynamic>{
      'id': id,
      'school_id': 9,
      'name': 'User $id',
      'email': 'u$id@test.id',
      'role': 'admin',
    };

void main() {
  tearDown(ApiClient.debugResetDio);

  group('recordPayment double-submit guard', () {
    test('overlapping calls for the same invoice: only one hits network',
        () async {
      int hits = 0;
      _useDio((RequestOptions o) async {
        hits++;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return _json(<String, dynamic>{'id': 7}, 200);
      });

      final FeesRepository repo = FeesRepository();
      final Future<Map<String, dynamic>> first =
          repo.recordPayment(invoiceId: 7, amount: 10000);
      await expectLater(
        repo.recordPayment(invoiceId: 7, amount: 10000),
        throwsA(isA<AppException>()),
      );
      await first;
      expect(hits, 1);
    });

    test('sequential payments for the same invoice are allowed', () async {
      int hits = 0;
      _useDio((RequestOptions o) async {
        hits++;
        return _json(<String, dynamic>{'id': 7}, 200);
      });

      final FeesRepository repo = FeesRepository();
      await repo.recordPayment(invoiceId: 7, amount: 5000);
      await repo.recordPayment(invoiceId: 7, amount: 5000);
      expect(hits, 2);
    });

    test('idempotency key is forwarded when provided', () async {
      Map<String, dynamic>? body;
      String? header;
      _useDio((RequestOptions o) async {
        body = Map<String, dynamic>.from(o.data as Map);
        header = o.headers['Idempotency-Key'] as String?;
        return _json(<String, dynamic>{'id': 7}, 200);
      });

      await FeesRepository().recordPayment(
        invoiceId: 7,
        amount: 10000,
        idempotencyKey: 'key-123',
      );
      expect(body?['idempotency_key'], 'key-123');
      expect(header, 'key-123');
    });
  });

  group('payment initiate idempotency', () {
    test('caller key is sent in header and body', () async {
      Map<String, dynamic>? body;
      String? header;
      _useDio((RequestOptions o) async {
        expect(o.path, ApiEndpoints.paymentInitiate);
        body = Map<String, dynamic>.from(o.data as Map);
        header = o.headers['Idempotency-Key'] as String?;
        return _json(<String, dynamic>{'reference_no': 'TX-1'}, 200);
      });

      await PaymentRepository().initiate(
        invoiceId: 7,
        paymentMethodId: 3,
        idempotencyKey: 'stable-key',
      );
      expect(body?['idempotency_key'], 'stable-key');
      expect(header, 'stable-key');
    });
  });

  group('login response hardening', () {
    test('200 without token raises ServerException, not TypeError', () async {
      _useDio((RequestOptions o) async =>
          _json(<String, dynamic>{'ok': true}, 200));

      await expectLater(
        AuthRepository().login(email: 'a@b.id', password: 'x'),
        throwsA(isA<ServerException>()),
      );
    });

    test('login as a different user wipes the offline outbox', () async {
      final InMemoryMutationStore mutations = InMemoryMutationStore();
      SyncEngine.instance.configureForTest(
        mutations: mutations,
        kv: InMemoryKvStore(),
      );
      await AppStorage.saveUser(_user(1));
      await mutations.enqueue(
        method: 'POST',
        path: '/chat/conversations/1/send',
        body: <String, dynamic>{'body': 'milik user 1'},
        idempotencyKey: 'k1',
      );
      expect(await mutations.pendingCount(), 1);

      _useDio((RequestOptions o) async => _json(<String, dynamic>{
            'token': 'tok-2',
            'user': _user(2),
          }, 200));

      await AuthRepository().login(email: 'u2@test.id', password: 'x');
      expect(await mutations.pendingCount(), 0);
    });

    test('login as the same user keeps the outbox', () async {
      final InMemoryMutationStore mutations = InMemoryMutationStore();
      SyncEngine.instance.configureForTest(
        mutations: mutations,
        kv: InMemoryKvStore(),
      );
      await AppStorage.saveUser(_user(1));
      await mutations.enqueue(
        method: 'POST',
        path: '/chat/conversations/1/send',
        body: <String, dynamic>{'body': 'milik user 1'},
        idempotencyKey: 'k1',
      );

      _useDio((RequestOptions o) async => _json(<String, dynamic>{
            'token': 'tok-1b',
            'user': _user(1),
          }, 200));

      await AuthRepository().login(email: 'u1@test.id', password: 'x');
      expect(await mutations.pendingCount(), 1);
      await AppStorage.clearAuth();
    });
  });
}
