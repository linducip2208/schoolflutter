import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Surat-menyurat. Backend: `LetterController` (`/letters*`,
/// school.manage|notice.manage). Nomor surat dibuat server.
class LettersRepository {
  Future<List<Map<String, dynamic>>> list() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.letters);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> templates() async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.letterTemplates,
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> store({
    required String recipientType,
    required String recipientName,
    required String subject,
    required String content,
    required String status,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.letters,
        data: <String, dynamic>{
          'recipient_type': recipientType,
          'recipient_name': recipientName,
          'subject': subject,
          'content': content,
          'status': status,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> updateStatus(int id, String status) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.letterStatus(id),
        data: <String, dynamic>{'status': status},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
