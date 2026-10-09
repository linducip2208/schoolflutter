import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/storage/app_storage.dart';

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

  /// Avatar upload: `POST /auth/avatar` multipart field `avatar`
  /// (image jpg/png/webp, max 2MB). Updates local session avatar.
  Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.updateAvatar,
        data: FormData.fromMap(<String, dynamic>{
          'avatar': await MultipartFile.fromFile(filePath),
        }),
      );
      final Map<String, dynamic> user = unwrapMap(r.data);
      final Map<String, dynamic>? stored = await AppStorage.getUser();
      if (stored != null) {
        stored['avatar_url'] = user['avatar_url'];
        await AppStorage.saveUser(stored);
      }
      return user;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
