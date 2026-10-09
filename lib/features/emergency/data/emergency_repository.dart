import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class EmergencyRepository {
  Future<void> panic({double? lat, double? lng, String? message}) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.emergencyPanic,
        data: <String, dynamic>{
          // Backend requires latitude/longitude (numeric, validated).
          if (lat != null) 'latitude': lat,
          if (lng != null) 'longitude': lng,
          if (message != null && message.isNotEmpty) 'message': message,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> recent() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.emergencyRecent);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> contacts() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.emergencyContacts);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Gate scan: backend expects `token` (+ optional device_info).
  Future<Map<String, dynamic>> qrScan(String payload) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.qrScan,
        data: <String, dynamic>{'token': payload},
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
