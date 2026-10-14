import 'package:dio/dio.dart';

import '../../../app/router/app_router.dart';
import '../../storage/app_storage.dart';

class ErrorInterceptor extends Interceptor {
  /// Auth endpoints manage their own error state (wrong password must
  /// keep the login form error, not force a logout cycle).
  static bool _isAuthAttempt(String path) =>
      path.contains('/auth/login') || path.contains('/auth/2fa');

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      if (_isAuthAttempt(err.requestOptions.path)) {
        // Wrong password / bad 2FA code: keep any stored session and let
        // the form show its own error (no logout cycle).
        handler.next(err);
        return;
      }
      await AppStorage.clearAuth();
      // expireSession flips auth state; the router redirect lands on login
      // exactly once (no explicit go() here — it raced the redirect).
      AppRouter.maybeInstance?.expireSession();
    }
    handler.next(err);
  }
}
