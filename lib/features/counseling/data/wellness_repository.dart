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

  Future<Map<String, dynamic>> scheduleSession({
    required int studentId,
    required int counselorId,
    required String scheduledAt,
    required String type,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.counselingSchedule,
        data: <String, dynamic>{
          'student_id': studentId,
          'counselor_id': counselorId,
          'scheduled_at': scheduledAt,
          'type': type,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> completeSession(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.counselingComplete(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> bullyingReports() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.bullyingReports);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> reportBullying({
    required String type,
    required String description,
    bool anonymous = false,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.bullyingReports,
        data: <String, dynamic>{
          'type': type,
          'description': description,
          'anonymous': anonymous,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> closeBullying(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.bullyingClose(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
