import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/sync/sync_engine.dart';

class AttendanceRepository {
  Future<List<Map<String, dynamic>>> mine({DateTime? from, DateTime? to}) async {
    final Map<String, dynamic> query = <String, dynamic>{
      if (from != null) 'from_date': from.toIso8601String().substring(0, 10),
      if (to != null) 'to_date': to.toIso8601String().substring(0, 10),
    };
    try {
      return await SyncEngine.instance.getCached<List<Map<String, dynamic>>>(
        cacheKey: cacheKey(ApiEndpoints.myAttendance, query),
        ttl: const Duration(minutes: 15),
        network: () async {
          final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
            ApiEndpoints.myAttendance,
            queryParameters: query,
          );
          return unwrapList(r.data);
        },
        encode: encodeList,
        decode: decodeList,
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> classRoster({
    required int sectionId,
    required DateTime date,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.attendanceByClass(sectionId),
        queryParameters: <String, dynamic>{
          'date': date.toIso8601String().substring(0, 10),
        },
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Offline-capable: queued to the outbox when the network is down and
  /// replayed with an Idempotency-Key (no duplicate attendance rows).
  Future<void> markAttendance({
    required int sectionId,
    required DateTime date,
    required Map<int, String> studentStatuses,
  }) async {
    try {
      final Response<dynamic> r = await SyncEngine.instance.postMutation(
        ApiEndpoints.attendanceByClass(sectionId),
        <String, dynamic>{
          'date': date.toIso8601String().substring(0, 10),
          'attendances': studentStatuses.entries
              .map((MapEntry<int, String> e) => <String, dynamic>{
                    'student_id': e.key,
                    'status': e.value,
                  })
              .toList(),
        },
      );
      // Touch response so 4xx (validation) still surfaces via Dio throw.
      if (r.statusCode != null && r.statusCode! >= 400) {
        throw DioException(requestOptions: r.requestOptions, response: r);
      }
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
