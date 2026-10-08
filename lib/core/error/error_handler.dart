import 'package:dio/dio.dart';

import 'app_exception.dart';

AppException mapDioError(DioException e) {
  if (e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return NetworkException('Koneksi timeout. Coba lagi.');
  }
  if (e.type == DioExceptionType.connectionError) {
    return NetworkException(
      'Tidak dapat terhubung ke server. Periksa koneksi internet.',
    );
  }
  if (e.type == DioExceptionType.cancel) {
    return AppException('Permintaan dibatalkan.');
  }
  if (e.type == DioExceptionType.badCertificate) {
    return AppException('Koneksi tidak aman. Hubungi admin sekolah.');
  }

  final Response<dynamic>? r = e.response;
  if (r == null) {
    // No response: offline / DNS / malformed.
    if (e.error is FormatException) {
      return AppException('Respons server tidak valid.');
    }
    return NetworkException(
      e.message ?? 'Tidak dapat terhubung ke server.',
    );
  }

  final dynamic data = r.data;
  final String msg = (data is Map && data['message'] is String)
      ? data['message'] as String
      : _fallbackMessage(r.statusCode);

  switch (r.statusCode) {
    case 401:
      return UnauthorizedException(msg);
    case 403:
      return ForbiddenException(msg);
    case 404:
      return AppException(msg, statusCode: 404);
    case 409:
      return AppException(msg, statusCode: 409);
    case 422:
      Map<String, List<String>>? errors;
      if (data is Map && data['errors'] is Map) {
        errors = (data['errors'] as Map<dynamic, dynamic>).map(
          (dynamic k, dynamic v) => MapEntry<String, List<String>>(
            k.toString(),
            (v as List<dynamic>).map((dynamic e) => e.toString()).toList(),
          ),
        );
      }
      return ValidationException(msg, errors: errors);
    case 429:
      return AppException(
        'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.',
        statusCode: 429,
      );
    case 500:
    case 502:
    case 503:
    case 504:
      return ServerException(
        'Server sedang bermasalah (${r.statusCode}). Coba lagi nanti.',
        statusCode: r.statusCode,
      );
    default:
      return ServerException(msg, statusCode: r.statusCode);
  }
}

String _fallbackMessage(int? code) => switch (code) {
      401 => 'Sesi berakhir. Silakan login kembali.',
      403 => 'Anda tidak memiliki akses.',
      404 => 'Data tidak ditemukan.',
      409 => 'Data bentrok. Muat ulang lalu coba lagi.',
      422 => 'Data tidak valid. Periksa isian formulir.',
      429 => 'Terlalu banyak permintaan. Coba lagi nanti.',
      500 || 502 || 503 || 504 => 'Server sedang bermasalah. Coba lagi nanti.',
      _ => 'Terjadi kesalahan ($code)',
    };
