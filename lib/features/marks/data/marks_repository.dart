import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class MarksRepository {
  Future<List<Map<String, dynamic>>> mine() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.myMarks);
      return unwrapList(r.data).map(_normalize).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> byStudent(int studentId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.marksByStudent(studentId),
      );
      return unwrapList(r.data).map(_normalize).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> reportCards(int studentId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.reportCardByStudent(studentId),
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Downloads report PDF to temp storage and opens it.
  Future<String> downloadReportPdf(int reportCardId) async {
    try {
      final Response<List<int>> r = await ApiClient.dio.get<List<int>>(
        ApiEndpoints.reportCardPdf(reportCardId),
        options: Options(responseType: ResponseType.bytes),
      );
      final Directory dir = await getTemporaryDirectory();
      final String file =
          '${dir.path}/rapor-$reportCardId-${DateTime.now().millisecondsSinceEpoch}.pdf';
      await File(file).writeAsBytes(r.data ?? <int>[]);
      await OpenFilex.open(file);
      return file;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Input nilai batch. Backend: `POST /marks/bulk`
  /// `{marks:[{student_id,subject_id,semester_id,exam_id?,
  /// obtained_marks,total_marks}]}` → `{saved:N}`.
  Future<int> bulk(List<Map<String, dynamic>> marks) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.marksBulk,
        data: <String, dynamic>{'marks': marks},
      );
      final Map<String, dynamic> body = unwrapMap(r.data);
      return (body['saved'] as num?)?.toInt() ?? marks.length;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> updateMark(int markId, {int? obtained, int? total}) async {
    try {
      await ApiClient.dio.put<dynamic>(
        ApiEndpoints.markUpdate(markId),
        data: <String, dynamic>{
          if (obtained != null) 'obtained_marks': obtained,
          if (total != null) 'total_marks': total,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> gradeSystems() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.gradeSystems);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Generate raport `{semester_id}` → `{generated:N}`.
  Future<int> generateReportCards(int semesterId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.reportCardsGenerate,
        data: <String, dynamic>{'semester_id': semesterId},
      );
      final Map<String, dynamic> body = unwrapMap(r.data);
      return (body['generated'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> publishReportCard(int reportCardId) async {
    try {
      await ApiClient.dio
          .post<dynamic>(ApiEndpoints.reportCardPublish(reportCardId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    final num obtained = (raw['obtained_marks'] as num?) ?? 0;
    final num total = (raw['total_marks'] as num?) ?? 100;
    final num pct = total == 0 ? 0 : (obtained / total) * 100;
    return <String, dynamic>{
      ...raw,
      'subject': raw['subject'] is Map
          ? (raw['subject'] as Map)['name']
          : raw['subject_name'] ?? raw['subject'],
      'exam_name': raw['exam'] is Map
          ? (raw['exam'] as Map)['name']
          : raw['exam_name'] ?? '-',
      'score': pct,
      'grade': raw['grade'] ?? _gradeFromPct(pct.toDouble()),
    };
  }

  String _gradeFromPct(double p) {
    if (p >= 90) return 'A';
    if (p >= 80) return 'B';
    if (p >= 70) return 'C';
    if (p >= 60) return 'D';
    return 'E';
  }
}
