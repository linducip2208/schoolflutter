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
}
