import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Beasiswa. Backend: `ScholarshipController` (`/scholarship/*`).
class ScholarshipsRepository {
  Future<List<Map<String, dynamic>>> programs() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.scholarshipPrograms);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeProgram({
    required String name,
    required String source,
    required String discountType,
    required int discountValue,
    required String openDate,
    required String closeDate,
    int? quota,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.scholarshipPrograms,
        data: <String, dynamic>{
          'name': name,
          'source': source,
          'discount_type': discountType,
          'discount_value': discountValue,
          'eligibility_criteria': <String>['Umum'],
          'open_date': openDate,
          'close_date': closeDate,
          if (quota != null) 'quota': quota,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> applications({int page = 1}) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.scholarshipApply,
        queryParameters: <String, dynamic>{
          'page': page,
        },
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> apply({
    required int programId,
    required int studentId,
    String? motivation,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.scholarshipApply,
        data: <String, dynamic>{
          'scholarship_program_id': programId,
          'student_id': studentId,
          if (motivation != null && motivation.isNotEmpty)
            'motivation': motivation,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> grant(int applicationId) async {
    try {
      await ApiClient.dio
          .post<dynamic>(ApiEndpoints.scholarshipGrant(applicationId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> applyToInvoice(int applicationId, int invoiceId) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.scholarshipApplyToInvoice(applicationId),
        data: <String, dynamic>{'invoice_id': invoiceId},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
