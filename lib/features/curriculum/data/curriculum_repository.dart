import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Kurikulum & CP/TP. Backend: `CurriculumController` (`/curriculum/*`).
class CurriculumRepository {
  Future<List<Map<String, dynamic>>> frameworks() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.currFrameworks);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeFramework({
    required String name,
    required String type,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.currFrameworks,
        data: <String, dynamic>{'name': name, 'type': type},
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> competencies({int? frameworkId}) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.currCompetencies,
        queryParameters: <String, dynamic>{
          if (frameworkId != null) 'framework_id': frameworkId,
        },
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeCompetency({
    required int frameworkId,
    required int subjectId,
    required int classRoomId,
    required String code,
    required String description,
    required String levelType,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.currCompetencies,
        data: <String, dynamic>{
          'curriculum_framework_id': frameworkId,
          'subject_id': subjectId,
          'class_room_id': classRoomId,
          'code': code,
          'description': description,
          'level_type': levelType,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> coverage() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.currCoverage);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
