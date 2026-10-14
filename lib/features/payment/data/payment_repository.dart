import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class PaymentRepository {
  Future<List<Map<String, dynamic>>> methods() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.paymentMethods);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Starts a gateway transaction. [idempotencyKey] is REQUIRED and must be
  /// stable across retries of the same user intent: the backend dedups on
  /// it for 24h, so a timeout-retry with a fresh key would double-charge.
  /// Callers must mint one key per (invoice, method) and reuse it until
  /// the intent succeeds or is abandoned.
  Future<Map<String, dynamic>> initiate({
    required int invoiceId,
    required int paymentMethodId,
    required String idempotencyKey,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.paymentInitiate,
        data: <String, dynamic>{
          'invoice_id': invoiceId,
          'payment_method_id': paymentMethodId,
          'idempotency_key': idempotencyKey,
        },
        options: Options(headers: <String, String>{
          'Idempotency-Key': idempotencyKey,
        }),
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> show(String referenceNo) async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .get<dynamic>(ApiEndpoints.paymentShow(referenceNo));
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> cancel(String referenceNo) async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .post<dynamic>(ApiEndpoints.paymentCancel(referenceNo));
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
