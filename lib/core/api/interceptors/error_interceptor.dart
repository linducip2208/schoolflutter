import 'package:dio/dio.dart';

import '../../../app/router/routes.dart';
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
      await AppStorage.clearAuth();
      if (_isAuthAttempt(err.requestOptions.path)) {
        handler.next(err);
        return;
      }
      AppRouter.maybeInstance?.expireSession();
      AppRouter.maybeInstance?.router.go(Routes.login);
    }
    handler.next(err);
  }
}
