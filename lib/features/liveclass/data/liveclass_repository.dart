import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Live class. Backend: `LiveClassController` (`/live-class/*`).
class LiveClassRepository {
  Future<List<Map<String, dynamic>>> sessions() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.liveSessions);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> schedule({
    required int classSectionId,
    required int subjectId,
    required String topic,
    required String scheduledStart,
    required int durationMinutes,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.liveSessions,
        data: <String, dynamic>{
          'class_section_id': classSectionId,
          'subject_id': subjectId,
          'topic': topic,
          'scheduled_start': scheduledStart,
          'duration_minutes': durationMinutes,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> join(int sessionId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .post<dynamic>(ApiEndpoints.liveClassJoin(sessionId));
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> start(int sessionId) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.liveStart(sessionId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> end(int sessionId) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.liveEnd(sessionId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
