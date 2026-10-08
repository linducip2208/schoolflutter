import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// RKAS / anggaran (rupiah penuh in/out).
/// Backend: `BudgetController` (`accounting.view|manage`).
class BudgetRepository {
  Future<Map<String, dynamic>> dashboard() async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.budgetDashboard,
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeCategory({
    required String name,
    required String code,
    required String type,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.budgetCategories,
        data: <String, dynamic>{
          'name': name,
          'code': code,
          'type': type,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeItem({
    required int categoryId,
    required String name,
    required int plannedAmount,
    required String status,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.budgetItems,
        data: <String, dynamic>{
          'budget_category_id': categoryId,
          'name': name,
          'planned_amount': plannedAmount,
          'status': status,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeTransaction({
    required int itemId,
    required String date,
    required int amount,
    String? description,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.budgetTransactions,
        data: <String, dynamic>{
          'budget_item_id': itemId,
          'transaction_date': date,
          'amount': amount,
          if (description != null && description.isNotEmpty)
            'description': description,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
