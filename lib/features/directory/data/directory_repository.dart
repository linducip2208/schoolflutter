import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Direktori sekolah: siswa, staf, referensi akademik.
/// Backend: `DirectoryController` (`/directory/*`, school-scoped).
class DirectoryRepository {
  Future<List<Map<String, dynamic>>> students({
    String? search,
    int? classSectionId,
    int page = 1,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.dirStudents,
        queryParameters: <String, dynamic>{
          if (search != null && search.isNotEmpty) 'search': search,
          if (classSectionId != null) 'class_section_id': classSectionId,
          'page': page,
        },
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> staff(
      {String? search, int page = 1}) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.dirStaff,
        queryParameters: <String, dynamic>{
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
        },
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> classSections() async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.dirClassSections,
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> subjects() async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.dirSubjects,
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> semesters() async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.dirSemesters,
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
