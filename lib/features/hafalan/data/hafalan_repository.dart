import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class HafalanRepository {
  Future<List<Map<String, dynamic>>> targets() async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.hafalanTargets,
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeTarget({
    required String name,
    required List<String> ranges,
    required String startDate,
    required String deadline,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.hafalanTargets,
        data: <String, dynamic>{
          'name': name,
          'target_ranges': ranges,
          'start_date': startDate,
          'deadline': deadline,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> summary(int studentId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.hafalanSummary(studentId),
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> record({
    required int studentId,
    required String surah,
    required int ayahStart,
    required int ayahEnd,
    required String quality,
    String? note,
    DateTime? memorizedAt,
  }) async {
    try {
      final DateTime at = memorizedAt ?? DateTime.now();
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.hafalanRecord,
        data: <String, dynamic>{
          'student_id': studentId,
          'surah': surah,
          'ayah_start': ayahStart,
          'ayah_end': ayahEnd,
          'memorized_at': at.toIso8601String().split('T').first,
          'quality': quality,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> logIbadah({
    required int studentId,
    required String type,
    String? note,
  }) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.ibadahLog,
        data: <String, dynamic>{
          'student_id': studentId,
          'type': type,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
