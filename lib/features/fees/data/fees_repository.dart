import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class FeesRepository {
  Future<List<Map<String, dynamic>>> mine() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.myFeeInvoices);
      return unwrapList(r.data).map(_normalize).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> all({String? status, int page = 1}) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.feeInvoices,
        queryParameters: <String, dynamic>{
          if (status != null) 'status': status,
          'page': page,
        },
      );
      return unwrapList(r.data).map(_normalize).toList();
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Triggers backend to create a payment link via configured gateway.
  Future<Map<String, dynamic>> initiatePayment(int invoiceId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .get<dynamic>(ApiEndpoints.invoicePaymentLink(invoiceId));
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> structures() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.feeStructures);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeStructure({
    required String name,
    required String frequency,
    required int amount,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.feeStructures,
        data: <String, dynamic>{
          'name': name,
          'frequency': frequency,
          'amount': amount,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Generate invoice sebulan (`{period: YYYY-MM}` → `{generated:N}`).
  Future<int> generateMonthly(String period) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.feeGenerateMonthly,
        data: <String, dynamic>{'period': period},
      );
      final Map<String, dynamic> body = unwrapMap(r.data);
      return (body['generated'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Catat pembayaran manual (`fee.payment`).
  Future<Map<String, dynamic>> recordPayment({
    required int invoiceId,
    required int amount,
    String method = 'cash',
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.invoicePay(invoiceId),
        data: <String, dynamic>{'amount': amount, 'payment_method': method},
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Map<String, dynamic> _normalize(Map<String, dynamic> raw) {
    return <String, dynamic>{
      ...raw,
      'title': raw['title'] ??
          (raw['fee_structure'] is Map
              ? (raw['fee_structure'] as Map)['name']
              : raw['period'] ?? raw['invoice_no'] ?? 'Invoice'),
      'due_at': raw['due_date'] ?? raw['due_at'],
    };
  }
}
