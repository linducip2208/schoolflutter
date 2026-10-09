import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:eschool_app/core/api/api_client.dart';
import 'package:eschool_app/core/api/api_endpoints.dart';
import 'package:eschool_app/core/error/app_exception.dart';
import 'package:eschool_app/core/utils/currency_formatter.dart';
import 'package:eschool_app/features/fees/data/fees_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rupiah regression: Rp10.000 stays Rp10.000 across
/// request → response → repository → display.
/// Backend (post pass-4) speaks whole rupiah; the app must NOT /100
/// on display nor x100 on send, and must NOT touch percents/qtys.
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

Dio _dioWith(Future<ResponseBody> Function(RequestOptions) handler) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfigForTest.base,
      validateStatus: (int? code) => code != null && code >= 200 && code < 300,
    ),
  );
  dio.httpClientAdapter = _FakeAdapter(handler);
  return dio;
}

class AppConfigForTest {
  static const String base = 'https://test.invalid/api/v1';
}

void main() {
  group('Rupiah regression (Rp10.000 end-to-end)', () {
    tearDown(ApiClient.debugResetDio);

    test('invoice amount passes through untouched, displays as Rp 10.000',
        () async {
      ApiClient.debugOverrideDio(_dioWith((RequestOptions o) async {
        expect(o.path, ApiEndpoints.feeInvoices);
        return _json(<dynamic>[
          <String, dynamic>{
            'id': 7,
            'amount': 10000,
            'paid_amount': 0,
            'status': 'unpaid',
          },
        ], 200);
      }));

      final List<Map<String, dynamic>> rows = await FeesRepository().all();
      expect(rows, hasLength(1));
      expect(rows.first['amount'], 10000);
      expect(CurrencyFormatter.idr(10000), contains('10.000'));
    });

    test('recordPayment sends the rupiah amount unchanged', () async {
      Map<String, dynamic>? captured;
      ApiClient.debugOverrideDio(_dioWith((RequestOptions o) async {
        captured = Map<String, dynamic>.from(o.data as Map);
        return _json(<String, dynamic>{'id': 7, 'amount': 10000}, 200);
      }));

      await FeesRepository()
          .recordPayment(invoiceId: 7, amount: 10000, method: 'cash');
      expect(captured?['amount'], 10000);
      expect(captured?['payment_method'], 'cash');
    });

    test('paginated envelope shape also parses', () async {
      ApiClient.debugOverrideDio(_dioWith((RequestOptions o) async {
        return _json(<String, dynamic>{
          'data': <dynamic>[
            <String, dynamic>{'id': 1, 'amount': 25000},
          ],
          'total': 1,
        }, 200);
      }));

      final List<Map<String, dynamic>> rows = await FeesRepository().all();
      expect(rows.first['amount'], 25000);
    });

    test('empty list parses (empty state)', () async {
      ApiClient.debugOverrideDio(
          _dioWith((RequestOptions o) async => _json(<dynamic>[], 200)));

      expect(await FeesRepository().all(), isEmpty);
    });

    test('401/403/422/500 map to typed exceptions', () async {
      Future<AppException> capture(int code, dynamic body) async {
        ApiClient.debugOverrideDio(
            _dioWith((RequestOptions o) async => _json(body, code)));
        try {
          await FeesRepository().all();
        } on AppException catch (e) {
          return e;
        }
        fail('expected AppException for $code');
      }

      expect((await capture(401, <String, dynamic>{'message': 'x'})).statusCode,
          401);
      expect((await capture(403, <String, dynamic>{'message': 'x'})).statusCode,
          403);
      final AppException v = await capture(422, <String, dynamic>{
        'message': 'invalid',
        'errors': {
          'amount': ['harus angka']
        },
      });
      expect(v, isA<ValidationException>());
      expect((await capture(500, <String, dynamic>{'message': 'boom'})),
          isA<ServerException>());
    });

    test('display never divides: idr/compact keep exact value', () {
      expect(CurrencyFormatter.idr(10000), contains('10.000'));
      expect(CurrencyFormatter.compact(10000), contains('Rp'));
      // Percent/points/qty are not money: untouched by formatters.
      expect(CurrencyFormatter.idr(15), isNot(contains('0,15')));
    });
  });
}
