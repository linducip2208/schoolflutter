import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class LmsRepository {
  Future<List<Map<String, dynamic>>> courses() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.lmsCourses);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> courseDetail(int courseId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.lmsCourseDetail(courseId),
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> enroll(int courseId) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.lmsEnroll,
        data: <String, dynamic>{'course_id': courseId},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> progress() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.lmsProgress);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> completeLesson(int lessonId) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.lmsCompleteLesson,
        data: <String, dynamic>{'lesson_id': lessonId},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> quizzes({int? courseId}) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.lmsQuizzes,
        queryParameters: <String, dynamic>{
          if (courseId != null) 'course_id': courseId,
        },
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> questions(int quizId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.quizQuestions(quizId),
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Backend expects answers keyed by question id: {"12": "A"}.
  Future<Map<String, dynamic>> submitQuiz({
    required int quizId,
    required Map<String, String> answers,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.lmsQuizSubmit,
        data: <String, dynamic>{'quiz_id': quizId, 'answers': answers},
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> certificate(int enrollmentId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.lmsCertificate(enrollmentId),
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
