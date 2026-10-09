import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class PpdbRepository {
  Future<List<Map<String, dynamic>>> periods(String subdomain) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.ppdbPeriods(subdomain),
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String subdomain,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.ppdbRegister(subdomain),
        data: payload,
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> submitApplication(int id) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.ppdbSubmit(id),
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> myApplications() async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.ppdbMyApplications,
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Upload dokumen aplikasi (`file` pdf/jpg/png ≤10MB + doc_type).
  Future<Map<String, dynamic>> uploadDoc({
    required int applicationId,
    required String filePath,
    required String docType,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.ppdbUploadDoc(applicationId),
        data: FormData.fromMap(<String, dynamic>{
          'file': await MultipartFile.fromFile(filePath),
          'doc_type': docType,
        }),
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Admin: daftar pendaftar (`role:admin`).
  Future<List<Map<String, dynamic>>> adminApplications({int page = 1}) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.ppdbAdminApplications,
        queryParameters: <String, dynamic>{'page': page},
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> verify(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.ppdbVerify(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> accept(int id, {String? note}) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.ppdbAccept(id),
        data: <String, dynamic>{if (note != null) 'note': note},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> reject(int id, String note) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.ppdbReject(id),
        data: <String, dynamic>{'note': note},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> reports() async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.ppdbReports,
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
