import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class LibraryRepository {
  Future<List<Map<String, dynamic>>> books({String? query}) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.libraryBooks,
        queryParameters: <String, dynamic>{
          if (query != null && query.isNotEmpty) 'q': query,
        },
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> issues() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.libraryIssues);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Backend issues to a USER (user_id), not a student row.
  Future<void> issue({required int bookId, required int userId}) async {
    try {
      await ApiClient.dio.post<dynamic>(
        ApiEndpoints.libraryIssue,
        data: <String, dynamic>{'book_id': bookId, 'user_id': userId},
      );
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> returnBook(int issueId) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.libraryReturn(issueId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> categories() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.libraryCategories);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> storeBook({
    required int categoryId,
    required String title,
    String? author,
    int? quantity,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.libraryStoreBook,
        data: <String, dynamic>{
          'book_category_id': categoryId,
          'title': title,
          if (author != null && author.isNotEmpty) 'author': author,
          if (quantity != null) 'total_quantity': quantity,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<int> markOverdue() async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .post<dynamic>(ApiEndpoints.libraryMarkOverdue);
      final Map<String, dynamic> body = unwrapMap(r.data);
      return (body['marked'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
