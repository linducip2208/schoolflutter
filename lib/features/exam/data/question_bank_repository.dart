import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Bank soal sekolah. Backend: `QuestionBankController`
/// (`/question-bank/*`, auth+school).
class QuestionBankRepository {
  Future<List<Map<String, dynamic>>> categories() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.qbCategories);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> items(
      {int? subjectId, int page = 1}) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.get<dynamic>(
        ApiEndpoints.qbItems,
        queryParameters: <String, dynamic>{
          if (subjectId != null) 'subject_id': subjectId,
          'page': page,
        },
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> store({
    required int subjectId,
    required String questionHtml,
    required String type,
    required List<String> answerKey,
    required String difficulty,
    required String cognitiveLevel,
    int? categoryId,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.qbItems,
        data: <String, dynamic>{
          'subject_id': subjectId,
          if (categoryId != null) 'question_bank_category_id': categoryId,
          'question_html': questionHtml,
          'type': type,
          'answer_key': answerKey,
          'difficulty': difficulty,
          'cognitive_level': cognitiveLevel,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  /// Generate soal dari bank: `{subject_id, distribution{easy,medium,
  /// hard}}` → `{data:[items]}`. Backend: `POST /question-bank/generate-exam`.
  Future<List<Map<String, dynamic>>> generateExam({
    required int subjectId,
    int easy = 0,
    int medium = 0,
    int hard = 0,
    int? categoryId,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.qbGenerateExam,
        data: <String, dynamic>{
          'subject_id': subjectId,
          if (categoryId != null) 'category_id': categoryId,
          'distribution': <String, dynamic>{
            'easy': easy,
            'medium': medium,
            'hard': hard,
          },
        },
      );
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
