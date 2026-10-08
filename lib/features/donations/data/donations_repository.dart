import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Donasi sekolah. Backend: `DonationController`
/// (`/admin/donations/*`, publik per subdomain).
class DonationsRepository {
  Future<List<Map<String, dynamic>>> campaigns() async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .get<dynamic>(ApiEndpoints.donationAdminCampaigns);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeCampaign({
    required String title,
    required String description,
    required int targetAmount,
    required String startDate,
    required String endDate,
    String? category,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.donationAdminCampaigns,
        data: <String, dynamic>{
          'title': title,
          'description': description,
          'target_amount': targetAmount,
          'start_date': startDate,
          'end_date': endDate,
          if (category != null) 'category': category,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> donations() async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .get<dynamic>(ApiEndpoints.donationAdminList);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> publicCampaigns(String subdomain) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.publicDonationCampaigns(subdomain),
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
