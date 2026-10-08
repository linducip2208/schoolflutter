import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class ExamRepository {
  Future<List<Map<String, dynamic>>> list() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.exams);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> questions(int examId) async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.examQuestions(examId));
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> create({
    required int classSectionId,
    required int subjectId,
    required String title,
    String type = 'offline',
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.exams,
        data: <String, dynamic>{
          'class_section_id': classSectionId,
          'subject_id': subjectId,
          'title': title,
          'type': type,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> remove(int examId) async {
    try {
      await ApiClient.dio.delete<dynamic>(ApiEndpoints.examDelete(examId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> addQuestion(
    int examId, {
    required String question,
    required String type,
    String? correctAnswer,
    int marks = 10,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.examStoreQuestion(examId),
        data: <String, dynamic>{
          'question': question,
          'type': type,
          'correct_answer': correctAnswer,
          'marks': marks,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> submissions(int examId) async {
    try {
      final Response<dynamic> r = await ApiClient.dio
          .get<dynamic>(ApiEndpoints.examSubmissions(examId));
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
