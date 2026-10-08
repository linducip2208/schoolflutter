import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class PayrollRepository {
  Future<List<Map<String, dynamic>>> slips() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.payrollSlips);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> structures() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.payrollStructures);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeStructure({
    required String name,
    required String type,
    required String calculation,
    required int value,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.payrollStructures,
        data: <String, dynamic>{
          'name': name,
          'type': type,
          'calculation': calculation,
          'value': value,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Generate slip (`{staff_id, month: YYYY-MM}`).
  Future<Map<String, dynamic>> generateSlip({
    required int staffId,
    required String month,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.payrollGenerateSlip,
        data: <String, dynamic>{'staff_id': staffId, 'month': month},
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> markPaid(int slipId) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.payrollMarkPaid(slipId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
