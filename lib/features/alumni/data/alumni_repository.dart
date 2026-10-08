import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Alumni. Backend: `AlumniController`
/// (`/alumni/profile`, `/admin/alumni/{id}/verify`).
class AlumniRepository {
  Future<Map<String, dynamic>> profile() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.alumniProfile);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.put<dynamic>(
        ApiEndpoints.alumniProfile,
        data: data,
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> verify(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.alumniVerify(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
