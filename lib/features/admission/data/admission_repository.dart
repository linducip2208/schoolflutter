import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class AdmissionRepository {
  Future<List<Map<String, dynamic>>> list() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.admission);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> stats() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.admissionStats);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
