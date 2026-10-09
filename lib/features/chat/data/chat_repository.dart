import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/sync/sync_engine.dart';

class ChatRepository {
  Future<List<Map<String, dynamic>>> conversations() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.conversations);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Backend: `POST /chat/conversations {recipient_id}` (same-school user).
  Future<Map<String, dynamic>> startConversation(int recipientId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.chatStart,
        data: <String, dynamic>{'recipient_id': recipientId},
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> messages(int conversationId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .get<dynamic>(ApiEndpoints.conversationMessages(conversationId));
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Offline-capable: queued when offline, replayed with Idempotency-Key.
  /// [file] is a backend upload path (see UploadRepository).
  Future<Map<String, dynamic>> send(int conversationId, String body,
      {String? file}) async {
    try {
      final Response<dynamic> r = await SyncEngine.instance.postMutation(
        ApiEndpoints.sendMessage(conversationId),
        <String, dynamic>{
          'body': body,
          if (file != null && file.isNotEmpty) 'file': file,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
