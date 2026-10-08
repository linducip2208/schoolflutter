import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class WellnessRepository {
  Future<void> checkin({
    required int studentId,
    required int mood,
    String? note,
  }) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.wellnessCheckin,
        data: <String, dynamic>{
          'student_id': studentId,
          'mood': mood,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> atRisk() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.wellnessAtRisk);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> sessions() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.counselingSessions);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
