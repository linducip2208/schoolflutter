import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

class AiAssistantRepository {
  /// Backend `runFeature` requires `messages:[{role,content}]`.
  Future<Map<String, dynamic>> ask({
    required String prompt,
    List<Map<String, String>>? history,
  }) async {
    try {
      final List<Map<String, String>> messages = <Map<String, String>>[
        if (history != null) ...history,
        <String, String>{'role': 'user', 'content': prompt},
      ];
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.aiStudyAssistant,
        data: <String, dynamic>{'messages': messages},
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> generateLessonPlan(String prompt) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.aiLessonPlan,
        data: <String, dynamic>{
          'messages': <Map<String, String>>[
            <String, String>{'role': 'user', 'content': prompt},
          ],
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> gradeEssay(String prompt) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.aiEssayGrade,
        data: <String, dynamic>{
          'messages': <Map<String, String>>[
            <String, String>{'role': 'user', 'content': prompt},
          ],
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
