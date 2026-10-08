import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Inventaris/aset. Backend: `InventoryController` (`/inventory/*`).
class InventoryRepository {
  Future<List<Map<String, dynamic>>> assets() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.invAssets);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeAsset({
    required int categoryId,
    required String name,
    String? location,
    int? purchasePrice,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.invAssets,
        data: <String, dynamic>{
          'asset_category_id': categoryId,
          'name': name,
          if (location != null && location.isNotEmpty) 'location': location,
          if (purchasePrice != null) 'purchase_price': purchasePrice,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> loans() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.invLoans);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> approveLoan(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.invApproveLoan(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> returnLoan(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.invReturnLoan(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> maintenance() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.invMaintenance);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> reportMaintenance({
    int? assetId,
    required String issue,
    String? priority,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.invMaintenance,
        data: <String, dynamic>{
          if (assetId != null) 'asset_id': assetId,
          'issue_description': issue,
          if (priority != null) 'priority': priority,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> resolveMaintenance(int id) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.invResolveMaintenance(id));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
