import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Tahun ajaran. Backend: `AcademicYearController` (`/academic-years*`).
class AcademicYearsRepository {
  Future<List<Map<String, dynamic>>> list() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.academicYears);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> store({
    required String name,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.academicYears,
        data: <String, dynamic>{
          'name': name,
          'start_date': startDate,
          'end_date': endDate,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> activate(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(
        '${ApiEndpoints.academicYears}/$id/activate',
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
