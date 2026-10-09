import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

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
      final Response<dynamic> r =
          await ApiClient.dio.post<dynamic>(ApiEndpoints.dapodikTest);
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

  Future<Map<String, dynamic>> importStudents(String filePath) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.dapodikImport,
        data: FormData.fromMap(<String, dynamic>{
          'file': await MultipartFile.fromFile(filePath),
        }),
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Export CSV siswa Dapodik → buka file.
  Future<String> exportStudents() async {
    try {
      final Response<List<int>> r = await ApiClient.dio.get<List<int>>(
        ApiEndpoints.dapodikExport,
        options: Options(responseType: ResponseType.bytes),
      );
      final Directory dir = await getTemporaryDirectory();
      final String file =
          '${dir.path}/dapodik-${DateTime.now().millisecondsSinceEpoch}.csv';
      await File(file).writeAsBytes(r.data ?? <int>[]);
      await OpenFilex.open(file);
      return file;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
