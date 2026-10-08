import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// AI provider BYOK (`role:admin`). Backend: `AiController` (`/admin/ai/*`).
/// Provider formats: openai_compatible, anthropic_format,
/// gemini_format, image_generic.
class AiAdminRepository {
  Future<List<Map<String, dynamic>>> providers() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.aiProviders);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeProvider({
    required String name,
    required String apiFormat,
    required String baseUrl,
    String? apiKey,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.aiProviders,
        data: <String, dynamic>{
          'name': name,
          'api_format': apiFormat,
          'base_url': baseUrl,
          if (apiKey != null && apiKey.isNotEmpty) 'api_key': apiKey,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> deleteProvider(int id) async {
    try {
      await ApiClient.dio.delete<dynamic>(ApiEndpoints.aiProvider(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> models() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.aiModels);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> features() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.aiFeatures);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> usage() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.aiUsage);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
