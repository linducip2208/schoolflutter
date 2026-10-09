import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class TransportRepository {
  Future<List<Map<String, dynamic>>> routes() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.transportRoutes);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> vehicles() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.transportVehicles);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeRoute({
    required String name,
    required List<String> stops,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.transportStoreRoute,
        data: <String, dynamic>{
          'name': name,
          'stops': stops
              .map((String s) => <String, dynamic>{'stop_name': s})
              .toList(),
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeVehicle({
    required String registrationNo,
    String? name,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.transportStoreVehicle,
        data: <String, dynamic>{
          'registration_no': registrationNo,
          if (name != null && name.isNotEmpty) 'name': name,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> assignStudent({
    required int studentId,
    required int routeId,
  }) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.transportAssign,
        data: <String, dynamic>{
          'student_id': studentId,
          'transport_route_id': routeId,
        },
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> activeTrips() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.transportActiveTrips);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> trackTrip(int tripId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.transportTrackTrip(tripId),
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
