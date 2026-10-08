import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// RPP digital. Backend: `LessonPlanController` (`/lesson-plans/*`).
class LessonPlanRepository {
  Future<List<Map<String, dynamic>>> list() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.lessonPlans);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> store({
    required int classSectionId,
    required int subjectId,
    required String title,
    required String lessonDate,
    required int durationMinutes,
    required List<String> objectives,
    required String materialSummary,
    required List<String> activities,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.lessonPlans,
        data: <String, dynamic>{
          'class_section_id': classSectionId,
          'subject_id': subjectId,
          'title': title,
          'lesson_date': lessonDate,
          'duration_minutes': durationMinutes,
          'learning_objectives': objectives,
          'material_summary': materialSummary,
          'activities': activities,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> submit(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.lessonPlanSubmit(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> approve(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.lessonPlanApprove(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> reject(int id, String feedback) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.lessonPlanReject(id),
        data: <String, dynamic>{'feedback': feedback},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> markExecuted(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.lessonPlanExecute(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
