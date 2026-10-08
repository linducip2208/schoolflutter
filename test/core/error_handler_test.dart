import 'package:dio/dio.dart';
import 'package:eschool_app/core/config/app_config.dart';
import 'package:eschool_app/core/error/app_exception.dart';
import 'package:eschool_app/core/error/error_handler.dart';
import 'package:eschool_app/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

Response<dynamic> _resp(int code, [dynamic data]) => Response<dynamic>(
      requestOptions: RequestOptions(path: '/x'),
      statusCode: code,
      data: data ?? <String, dynamic>{'message': 'm'},
    );

DioException _err(DioExceptionType t, {Response<dynamic>? r}) => DioException(
    requestOptions: RequestOptions(path: '/x'), type: t, response: r);

void main() {
  group('mapDioError', () {
    test('404 maps to AppException with 404', () {
      final AppException e = mapDioError(
        _err(DioExceptionType.badResponse, r: _resp(404)),
      );
      expect(e.statusCode, 404);
    });
    test('409 maps to AppException with 409', () {
      final AppException e = mapDioError(
        _err(DioExceptionType.badResponse, r: _resp(409)),
      );
      expect(e.statusCode, 409);
    });
    test('429 user-friendly rate-limit message', () {
      final AppException e = mapDioError(
        _err(DioExceptionType.badResponse, r: _resp(429)),
      );
      expect(e.statusCode, 429);
      expect(e.message, contains('Terlalu banyak'));
    });
    test('500 maps to ServerException', () {
      final AppException e = mapDioError(
        _err(DioExceptionType.badResponse, r: _resp(500)),
      );
      expect(e, isA<ServerException>());
    });
    test('cancel maps to AppException', () {
      final AppException e = mapDioError(_err(DioExceptionType.cancel));
      expect(e.message, contains('dibatalkan'));
    });
    test('422 preserves field errors', () {
      final AppException e = mapDioError(
        _err(
          DioExceptionType.badResponse,
          r: _resp(422, <String, dynamic>{
            'message': 'invalid',
            'errors': {
              'email': ['salah']
            },
          }),
        ),
      );
      expect(e, isA<ValidationException>());
      expect((e as ValidationException).errors?['email'], <String>['salah']);
    });
  });

  group('Currency IDR', () {
    test('whole rupiah, no divide-by-100', () {
      expect(CurrencyFormatter.idr(15000), contains('15.000'));
      expect(CurrencyFormatter.idr(15000), isNot(contains('150')));
    });
    test('compact keeps Rp', () {
      expect(CurrencyFormatter.compact(1500000), contains('Rp'));
    });
  });

  group('AppConfig', () {
    test('default dev URL is emulator loopback (expected)', () {
      expect(AppConfig.apiBaseUrl, contains('10.0.2.2'));
    });
    test('isReleaseUrlSafe flags dev URL as unsafe for release', () {
      // Default dart-define is dev; release CI must override.
      expect(AppConfig.isReleaseUrlSafe, isFalse);
    });
  });
}
