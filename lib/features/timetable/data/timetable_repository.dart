import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';
import '../../../core/sync/sync_engine.dart';

class TimetableRepository {
  /// Role-aware schedule: students & parents use the student endpoint,
  /// teachers & staff use the "my schedule" endpoint.
  Future<Map<String, List<Map<String, dynamic>>>> mine({String role = 'student'}) async {
    if (role == 'student' || role == 'parent') {
      return studentSchedule();
    }
    return teacherSchedule();
  }
  /// For students. Backend returns array; we group by `day_of_week`.
  /// Offline-capable: serves the 6-hour cache when the network is down.
  Future<Map<String, List<Map<String, dynamic>>>> studentSchedule() async {
    try {
      final List<Map<String, dynamic>> items =
          await SyncEngine.instance.getCached<List<Map<String, dynamic>>>(
        cacheKey: cacheKey(ApiEndpoints.timetableStudentMy),
        ttl: const Duration(hours: 6),
        network: () async {
          final Response<dynamic> r = await ApiClient.dio
              .get<dynamic>(ApiEndpoints.timetableStudentMy);
          return unwrapList(r.data);
        },
        encode: encodeList,
        decode: decodeList,
      );
      return _groupByDay(items);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// For teachers (or anyone with `teacher_id` resolvable on backend).
  /// Offline-capable: serves the 6-hour cache when the network is down.
  Future<Map<String, List<Map<String, dynamic>>>> teacherSchedule() async {
    try {
      final List<Map<String, dynamic>> items =
          await SyncEngine.instance.getCached<List<Map<String, dynamic>>>(
        cacheKey: cacheKey(ApiEndpoints.timetableMy),
        ttl: const Duration(hours: 6),
        network: () async {
          final Response<dynamic> r =
              await ApiClient.dio.get<dynamic>(ApiEndpoints.timetableMy);
          return unwrapList(r.data);
        },
        encode: encodeList,
        decode: decodeList,
      );
      return _groupByDay(items);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  static const Map<int, String> _dayKey = <int, String>{
    1: 'monday',
    2: 'tuesday',
    3: 'wednesday',
    4: 'thursday',
    5: 'friday',
    6: 'saturday',
    7: 'sunday',
  };

  Map<String, List<Map<String, dynamic>>> _groupByDay(
      List<Map<String, dynamic>> items) {
    final Map<String, List<Map<String, dynamic>>> out = <String, List<Map<String, dynamic>>>{
      for (final String d in _dayKey.values) d: <Map<String, dynamic>>[],
    };
    for (final Map<String, dynamic> s in items) {
      final dynamic raw = s['day_of_week'];
      String? key;
      if (raw is num) key = _dayKey[raw.toInt()];
      if (raw is String) key = _dayKey[int.tryParse(raw) ?? 0] ?? raw.toLowerCase();
      key ??= 'monday';
      out[key]!.add(<String, dynamic>{
        ...s,
        'subject': s['subject'] is Map
            ? (s['subject'] as Map)['name']
            : s['subject_name'] ?? s['subject'],
        'teacher': s['teacher'] is Map
            ? (s['teacher'] as Map)['name']
            : s['teacher_name'] ?? s['teacher'],
        'start': _trim(s['start_time'] ?? s['start']),
        'end': _trim(s['end_time'] ?? s['end']),
      });
    }
    return out;
  }

  String? _trim(dynamic v) {
    if (v == null) return null;
    final String s = v.toString();
    return s.length >= 5 ? s.substring(0, 5) : s;
  }
}
