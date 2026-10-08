import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Konfigurasi payment provider BYOK (`role:admin`).
/// Backend: `PaymentProviderController`, `PaymentMethodController`.
class PaymentAdminRepository {
  Future<List<Map<String, dynamic>>> providers() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.payProviders);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeProvider({
    required String name,
    required String apiFormat,
    String? apiKey,
    String? secretKey,
    bool isSandbox = true,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.payProviders,
        data: <String, dynamic>{
          'name': name,
          'api_format': apiFormat,
          if (apiKey != null && apiKey.isNotEmpty) 'api_key': apiKey,
          if (secretKey != null && secretKey.isNotEmpty)
            'secret_key': secretKey,
          'is_sandbox': isSandbox,
          'is_active': true,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> testProvider(int id) async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .post<dynamic>(ApiEndpoints.payProviderTest(id));
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> methods() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.payMethodsAdmin);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeMethod({
    required int providerId,
    required String code,
    required String displayName,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.payMethodsAdmin,
        data: <String, dynamic>{
          'payment_provider_id': providerId,
          'code': code,
          'display_name': displayName,
          'is_active': true,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
