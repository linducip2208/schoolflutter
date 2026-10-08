import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Profile & account-security operations.
///
/// Backend contract (Laravel):
/// - GET  /auth/me              → current user (UserResource)
/// - PUT  /auth/profile         → update name/phone (method-spoofed via POST)
/// - POST /auth/avatar          → multipart avatar (400x400 jpg)
/// - POST /auth/change-password→ {current_password, password, ...}
class ProfileRepository {
  Future<Map<String, dynamic>> me() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.me);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Backend route is PUT /auth/profile. Dio PUT is used directly so the
  /// request matches routes/api.php without _method spoofing.
  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> payload,
  ) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.put<dynamic>(
        ApiEndpoints.updateProfile,
        data: payload,
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
