import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/notifications/fcm_service.dart';
import '../../../core/storage/app_storage.dart';
import '../../../core/sync/sync_engine.dart';
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
        throw ServerException(_message(r.data, 'Login gagal'));
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
        throw ServerException(_message(r.data, 'Verifikasi gagal'));
      }
      return _storeSession(Map<String, dynamic>.from(r.data as Map));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Safe message extractor: never throws on malformed bodies
  /// (a `TypeError` here would crash instead of surfacing [ServerException]).
  static String _message(dynamic data, String fallback) {
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }

  Future<AuthSession> _storeSession(Map<String, dynamic> body) async {
    final dynamic rawToken = body['token'];
    final dynamic rawUser = body['user'];
    if (rawToken is! String || rawToken.isEmpty || rawUser is! Map) {
      throw ServerException('Respons login tidak valid.');
    }
    final String token = rawToken;
    final Map<String, dynamic> userMap = Map<String, dynamic>.from(rawUser);
    final Map<String, dynamic>? schoolMap = userMap['school'] is Map
        ? Map<String, dynamic>.from(userMap['school'] as Map)
        : null;

    final UserModel user = UserModel.fromJson(userMap);
    final SchoolModel school = schoolMap != null
        ? SchoolModel.fromJson(schoolMap)
        : SchoolModel(id: user.schoolId, name: '');

    // P0 guard: the offline outbox replays with the CURRENT token, so a
    // leftover queue from another user would be sent as the new user.
    // Wipe local data when the identity changes (or when no session
    // existed but an orphan queue survived, e.g. reinstall edge cases).
    final Map<String, dynamic>? previous = await AppStorage.getUser();
    final dynamic previousId = previous?['id'];
    if (previousId != user.id) {
      await SyncEngine.instance.clearLocal();
    }

    await AppStorage.saveToken(token);
    await AppStorage.saveUser(user.toJson());
    await AppStorage.saveSchool(school.toJson());

    return AuthSession(user: user, school: school, token: token);
  }

  /// Validates a restored session against the server (`GET /auth/me`).
  /// Returns true when the session is usable. A 401 lets the global
  /// [ErrorInterceptor] expire the session; any network failure keeps the
  /// cached session so offline boot still works.
  Future<bool> validateSession() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.me);
      final dynamic data = r.data;
      Map<String, dynamic>? userMap;
      if (data is Map && data['user'] is Map) {
        userMap = Map<String, dynamic>.from(data['user'] as Map);
      } else if (data is Map && data['data'] is Map) {
        final dynamic inner = (data['data'] as Map)['user'];
        if (inner is Map) userMap = Map<String, dynamic>.from(inner);
      } else if (data is Map && data['id'] != null) {
        userMap = Map<String, dynamic>.from(data);
      }
      if (userMap != null) {
        await AppStorage.saveUser(userMap);
      }
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return false;
      return true;
    }
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
    await SyncEngine.instance.clearLocal();
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
