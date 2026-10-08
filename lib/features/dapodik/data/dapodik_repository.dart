import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Sinkronisasi Dapodik. Backend: `DapodikController`
/// (`/admin/dapodik/*`, `role_or_permission:admin|dapodik.sync`).
class DapodikRepository {
  Future<Map<String, dynamic>> config() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.dapodikConfig);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateConfig(Map<String, dynamic> data) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.put<dynamic>(
        ApiEndpoints.dapodikConfig,
        data: data,
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> testConnection() async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .post<dynamic>(ApiEndpoints.dapodikTest);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> runs() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.dapodikRuns);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> conflicts() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.dapodikConflicts);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> resolveConflict(int id, String resolution) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.dapodikResolveConflict(id),
        data: <String, dynamic>{'resolution': resolution},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> confirmRun(int runId) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.dapodikConfirmRun(runId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
