import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/sync/sync_engine.dart';

class ClassroomRepository {
  Future<List<Map<String, dynamic>>> assignments() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.classroomAssignments);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> lessons() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.classroomLessons);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Offline-capable submission: queued when offline (server upserts per
  /// student so replayed retries never duplicate the submission).
  /// Backend fields: `answer` (text) and `file` (attachment URL/path).
  Future<void> submitAssignment(int assignmentId,
      {String? answer, String? file}) async {
    try {
      await SyncEngine.instance.postMutation(
        ApiEndpoints.submitAssignment(assignmentId),
        <String, dynamic>{
          if (answer != null) 'answer': answer,
          if (file != null) 'file': file,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
