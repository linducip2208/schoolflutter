import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class DailyReportRepository {
  Future<List<Map<String, dynamic>>> forChild(int studentId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.childDailyReports(studentId),
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Admin: generate laporan harian (`role:admin`).
  Future<Map<String, dynamic>> generate(Map<String, dynamic> payload) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.dailyReportGenerate,
        data: payload,
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> send(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.dailyReportSend(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
