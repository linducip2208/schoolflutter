import 'dart:io' show File;
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import '../error/error_handler.dart';

/// Secure file upload for mobile.
///
/// Backend: `POST /uploads {file, purpose}` — MIME/size validated
/// server-side, random filenames, school-scoped paths.
/// Purposes: chat, assignment (public images) · ppdb, medical,
/// payment_proof (private, via [downloadBytes]).
class UploadRepository {
  /// Uploads [file] with progress + cancellation support.
  /// Returns the decoded JSON: {path, url?, purpose, size, mime}.
  Future<Map<String, dynamic>> upload({
    required File file,
    required String purpose,
    void Function(int sent, int total)? onProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      final String name = file.path.split(RegExp(r'[\\/]')).last;
      final FormData form = FormData.fromMap(<String, dynamic>{
        'purpose': purpose,
        'file': await MultipartFile.fromFile(file.path, filename: name),
      });
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.uploads,
        data: form,
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
        onSendProgress: onProgress,
        cancelToken: cancelToken,
      );
      if (r.data is Map) return Map<String, dynamic>.from(r.data as Map);
      throw const FormatException('Respons upload tidak valid');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Downloads a private file as bytes (authorized `GET /uploads/file`).
  Future<Uint8List> downloadBytes(String path) async {
    try {
      final Response<List<int>> r = await ApiClient.dio.get<List<int>>(
        ApiEndpoints.uploadFile,
        queryParameters: <String, String>{'path': path},
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(r.data ?? <int>[]);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Resolves a backend file reference to a displayable URL.
  /// Absolute URLs pass through; public storage paths are prefixed with
  /// the server origin; anything else (private paths) needs [downloadBytes].
  static String displayUrl(String ref) {
    if (ref.startsWith('http://') || ref.startsWith('https://')) return ref;
    final String clean = ref.startsWith('/') ? ref : '/$ref';
    if (clean.startsWith('/storage/')) return '${AppConfig.fileBaseUrl}$clean';
    return ref;
  }

  static bool looksLikeImage(String ref) {
    final String lower = ref.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }
}
