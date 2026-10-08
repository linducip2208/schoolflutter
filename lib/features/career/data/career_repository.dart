import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Karier/BKK. Backend: `CareerController` (`/career/*`).
class CareerRepository {
  Future<List<Map<String, dynamic>>> internships() async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .get<dynamic>(ApiEndpoints.careerInternships);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeInternship({
    required int studentId,
    required String company,
    required String position,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.careerInternships,
        data: <String, dynamic>{
          'student_id': studentId,
          'company_name': company,
          'position': position,
          'start_date': startDate,
          'end_date': endDate,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> studentAssessments(int studentId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.careerStudentAssess(studentId),
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> recordAssessment({
    required int studentId,
    required String testType,
    required List<String> responses,
    required Map<String, dynamic> result,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.careerAssess,
        data: <String, dynamic>{
          'student_id': studentId,
          'test_type': testType,
          'responses': responses,
          'result': result,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> logActivity(int internshipId, String activity) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.careerLogActivity(internshipId),
        data: <String, dynamic>{'activity': activity},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
