import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Ekstrakurikuler. Backend: `ExtracurricularController` (`/ekskul*`).
class EkskulRepository {
  Future<List<Map<String, dynamic>>> list() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.ekskul);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> store({
    required String name,
    String? description,
    int? capacity,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.ekskul,
        data: <String, dynamic>{
          'name': name,
          if (description != null && description.isNotEmpty)
            'description': description,
          if (capacity != null) 'capacity': capacity,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> enroll(int ekskulId, int studentId) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.ekskulEnroll(ekskulId),
        data: <String, dynamic>{'student_id': studentId},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> markAttendance(
    int ekskulId,
    String sessionDate,
    List<Map<String, dynamic>> attendances,
  ) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.ekskulAttendance(ekskulId),
        data: <String, dynamic>{
          'session_date': sessionDate,
          'attendances': attendances,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
