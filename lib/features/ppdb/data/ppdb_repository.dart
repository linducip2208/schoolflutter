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
}
