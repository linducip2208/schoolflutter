import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import '../../storage/app_storage.dart';

/// Attaches the bearer token + JSON/mail headers to every request.
/// Also stamps a fresh `Idempotency-Key` on every mutating request
/// (POST/PUT/PATCH/DELETE) that doesn't carry one yet, so an accidental
/// double-submit can never create two server rows on endpoints that
/// honor the key (chat, canteen, payments; SyncEngine replays keep
/// their own stored key and are left untouched).
class AuthInterceptor extends Interceptor {
  static const Uuid _uuid = Uuid();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? token = await AppStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['X-App-Platform'] = 'mobile';
    if (options.method != 'GET' &&
        !options.headers.containsKey('Idempotency-Key')) {
      options.headers['Idempotency-Key'] = _uuid.v4();
    }
    handler.next(options);
  }
}
