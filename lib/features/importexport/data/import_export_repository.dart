import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/error/error_handler.dart';

/// Bulk import/export CSV. Backend: `ImportExportController`
/// (multipart field `file`; export mengembalikan bytes CSV).
class ImportExportRepository {
  Future<Map<String, dynamic>> importStudents(String filePath) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.importStudents,
        data: FormData.fromMap(<String, dynamic>{
          'file': await MultipartFile.fromFile(filePath),
        }),
      );
      return r.data is Map
          ? Map<String, dynamic>.from(r.data as Map)
          : <String, dynamic>{'ok': true};
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Downloads a CSV export (`marks`|`fee`) to temp storage and opens it.
  Future<String> downloadExport(String kind) async {
    final String path = kind == 'fee'
        ? ApiEndpoints.exportFeeCollection
        : ApiEndpoints.exportMarks;
    try {
      final Response<List<int>> r = await ApiClient.dio.get<List<int>>(
        path,
        options: Options(responseType: ResponseType.bytes),
      );
      final Directory dir = await getTemporaryDirectory();
      final String file =
          '${dir.path}/export-$kind-${DateTime.now().millisecondsSinceEpoch}.csv';
      await File(file).writeAsBytes(r.data ?? <int>[]);
      await OpenFilex.open(file);
      return file;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
