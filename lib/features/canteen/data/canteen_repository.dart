import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/error/error_handler.dart';

class CanteenRepository {
  Future<Map<String, dynamic>> menu() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.canteenMenu);
      final Map<String, dynamic> body = r.data is Map
          ? Map<String, dynamic>.from(r.data as Map)
          : <String, dynamic>{};
      return body;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> wallet(int studentId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.canteenWallet(studentId),
      );
      return r.data is Map
          ? Map<String, dynamic>.from(r.data as Map)
          : <String, dynamic>{};
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> order({
    required int studentId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.canteenOrder,
        data: <String, dynamic>{
          'student_id': studentId,
          'items': items,
          'source': 'preorder',
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> topup({required int studentId, required int amount}) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.canteenTopup(studentId),
        data: <String, dynamic>{'amount': amount},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
