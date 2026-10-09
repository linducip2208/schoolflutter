import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';

class ApiClient {
  ApiClient._();

  static late final Dio _dio;

  /// Test seam: when set, [dio] returns the override instead of [_dio].
  /// Repositories intentionally keep using [dio] so contract tests can
  /// drive them with a fake [HttpClientAdapter] (no network).
  static Dio? _debugDio;

  static Dio get dio => _debugDio ?? _dio;

  @visibleForTesting
  static void debugOverrideDio(Dio dio) => _debugDio = dio;

  @visibleForTesting
  static void debugResetDio() => _debugDio = null;

  static void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (int? code) =>
            code != null && code >= 200 && code < 300,
      ),
    )..interceptors.addAll(<Interceptor>[
        AuthInterceptor(),
        ErrorInterceptor(),
        if (kDebugMode)
          PrettyDioLogger(
            requestHeader: false,
            requestBody: true,
            responseBody: true,
            error: true,
            compact: true,
            maxWidth: 100,
          ),
      ]);
  }
}
