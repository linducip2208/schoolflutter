import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/notifications/fcm_service.dart';
import '../../../core/storage/app_storage.dart';
import 'models/school_model.dart';
import 'models/user_model.dart';

class AuthSession {
  AuthSession({required this.user, required this.school, required this.token});
  final UserModel user;
  final SchoolModel school;
  final String token;
}

/// Thrown when the account requires a second factor. The UI must route
/// to the 2FA screen and call [AuthRepository.verifyTwoFactor].
class TwoFactorRequired implements Exception {
  TwoFactorRequired(this.challengeId);
  final String challengeId;

  String get message => 'Verifikasi dua langkah diperlukan.';
  @override
  String toString() => message;
}

class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
    String? schoolCode,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.login,
        data: <String, dynamic>{
          'email': email,
          'password': password,
          'device_name': 'mobile',
          if (schoolCode != null && schoolCode.isNotEmpty)
            'school_code': schoolCode,
        },
      );
      if (r.statusCode == 202 && r.data is Map) {
        final Map<String, dynamic> body =
            Map<String, dynamic>.from(r.data as Map);
        final String? challengeId = body['challenge_id'] as String?;
        if (body['two_factor_required'] == true && challengeId != null) {
          throw TwoFactorRequired(challengeId);
        }
      }
      if (r.statusCode != 200 || r.data is! Map) {
        throw ServerException(
          (r.data is Map ? r.data['message'] : 'Login gagal') as String,
        );
      }

      return _storeSession(Map<String, dynamic>.from(r.data as Map));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<AuthSession> verifyTwoFactor({
    required String challengeId,
    String? code,
    String? recoveryCode,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.twoFactorVerify,
        data: <String, dynamic>{
          'challenge_id': challengeId,
          if (code != null && code.isNotEmpty) 'two_factor_code': code,
          if (recoveryCode != null && recoveryCode.isNotEmpty)
            'recovery_code': recoveryCode,
          'device_name': 'mobile',
        },
      );
      if (r.statusCode != 200 || r.data is! Map) {
        throw ServerException(
          (r.data is Map ? r.data['message'] : 'Verifikasi gagal') as String,
        );
      }
      return _storeSession(Map<String, dynamic>.from(r.data as Map));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<AuthSession> _storeSession(Map<String, dynamic> body) async {
    final String token = body['token'] as String;
    final Map<String, dynamic> userMap =
        Map<String, dynamic>.from(body['user'] as Map);
    final Map<String, dynamic>? schoolMap = userMap['school'] is Map
        ? Map<String, dynamic>.from(userMap['school'] as Map)
        : null;

    final UserModel user = UserModel.fromJson(userMap);
    final SchoolModel school = schoolMap != null
        ? SchoolModel.fromJson(schoolMap)
        : SchoolModel(id: user.schoolId, name: '');

    await AppStorage.saveToken(token);
    await AppStorage.saveUser(user.toJson());
    await AppStorage.saveSchool(school.toJson());

    return AuthSession(user: user, school: school, token: token);
  }

  Future<void> forgotPassword(String email) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.forgotPassword,
        data: <String, String>{'email': email},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<AuthSession?> restoreSession() async {
    final String? token = await AppStorage.getToken();
    final Map<String, dynamic>? user = await AppStorage.getUser();
    final Map<String, dynamic>? school = await AppStorage.getSchool();
    if (token == null || user == null || school == null) return null;
    return AuthSession(
      user: UserModel.fromJson(user),
      school: SchoolModel.fromJson(school),
      token: token,
    );
  }

  Future<void> logout() async {
    try {
      // Remove this device from push registry first (still authenticated).
      await FcmService.instance.unregisterFromBackend();
    } catch (_) {
      // best effort
    }
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.logout);
    } catch (_) {
      // best effort — local clear regardless
    }
    await AppStorage.clearAuth();
  }

  Future<void> changePassword({
    required String current,
    required String next,
  }) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.changePassword,
        data: <String, String>{
          'current_password': current,
          'password': next,
          'password_confirmation': next,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
