import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Platform-level data for `super_admin`.
/// Backend: `GET /api/v1/super/*` (`role:super_admin`, bypass SchoolScope).
class SuperAdminRepository {
  /// Paginated schools list (`paginate(20)`). Returns raw school maps;
  /// supports `search` (by name) and `status` (`active`/`inactive`).
  Future<List<Map<String, dynamic>>> fetchSchools({
    String? search,
    String? status,
    int page = 1,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.superSchools,
        queryParameters: <String, dynamic>{
          'page': page,
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Detail of one school (`with plan`).
  Future<Map<String, dynamic>> fetchSchoolDetail(int id) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.superSchoolDetail(id),
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> activityLog(int schoolId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.superSchoolActivity(schoolId),
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> suspendSchool(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.superSchoolSuspend(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> activateSchool(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.superSchoolActivate(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> extendSubscription(int id, String expiresAt) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.superSchoolExtend(id),
        data: <String, dynamic>{'plan_expires_at': expiresAt},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> plans() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.superPlans);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> subscriptions() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.superSubscriptions);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> revenueAnalytics() async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .get<dynamic>(ApiEndpoints.superRevenueAnalytics);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> growthAnalytics() async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .get<dynamic>(ApiEndpoints.superGrowthAnalytics);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> systemConfig() async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .get<dynamic>(ApiEndpoints.superSystemConfig);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateSystemConfig(
      Map<String, dynamic> data) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.put<dynamic>(
        ApiEndpoints.superSystemConfig,
        data: data,
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> deepHealth() async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .get<dynamic>(ApiEndpoints.apiDeepHealth);
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
