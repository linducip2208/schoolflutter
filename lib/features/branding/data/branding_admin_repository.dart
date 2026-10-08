import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Branding sekolah (white-label). Backend: `BrandingController`
/// (`GET /branding`, `PUT /admin/branding`, logo upload/reset).
class BrandingAdminRepository {
  Future<Map<String, dynamic>> mine() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.brandingMine);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> update(Map<String, dynamic> data) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.put<dynamic>(
        '/admin/branding',
        data: data,
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> uploadLogo(String filePath) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        '/admin/branding/upload-logo',
        data: FormData.fromMap(<String, dynamic>{
          'logo': await MultipartFile.fromFile(filePath),
        }),
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
