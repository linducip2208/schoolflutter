import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Visitor management. Backend: `VisitorController` (`/visitors*`).
class VisitorsRepository {
  Future<List<Map<String, dynamic>>> active() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.visitorsActive);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> list({int page = 1}) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.visitors,
        queryParameters: <String, dynamic>{
          'page': page,
        },
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> checkIn({
    required String name,
    required String purpose,
    String? phone,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.visitorCheckIn,
        data: <String, dynamic>{
          'name': name,
          'purpose': purpose,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> approve(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.visitorApprove(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> checkOut(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.visitorCheckOut(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
