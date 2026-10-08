import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class NoticeRepository {
  Future<List<Map<String, dynamic>>> list() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.notices);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Backend field is `content` (bukan `body`).
  Future<void> create({
    required String title,
    required String body,
    List<String>? targetRoles,
    String? publishAt,
    String? expireAt,
  }) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.notices,
        data: <String, dynamic>{
          'title': title,
          'content': body,
          'is_published': true,
          if (targetRoles != null && targetRoles.isNotEmpty)
            'target_roles': targetRoles,
          if (publishAt != null && publishAt.isNotEmpty)
            'publish_at': publishAt,
          if (expireAt != null && expireAt.isNotEmpty)
            'expire_at': expireAt,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> remove(int id) async {
    try {
      await ApiClient.dio.delete<dynamic>('${ApiEndpoints.notices}/$id');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
