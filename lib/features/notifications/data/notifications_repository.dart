import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class NotificationsRepository {
  Future<List<Map<String, dynamic>>> list({int page = 1}) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.notifications,
        queryParameters: <String, dynamic>{'page': page},
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<int> unreadCount() async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.notificationsUnreadCount,
      );
      final Map<String, dynamic> body = unwrapMap(r.data);
      final dynamic c =
          body['unread_count'] ?? body['count'] ?? body['total'] ?? 0;
      return (c as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> markRead(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.markNotificationRead(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.markAllNotificationsRead,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
