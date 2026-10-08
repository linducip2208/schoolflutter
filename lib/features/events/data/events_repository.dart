import 'package:dio/dio.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/response_unwrap.dart';
import '../../../core/error/error_handler.dart';

/// Event sekolah + RSVP. Backend: `EventController`
/// (`GET /events` adminList, `POST /events`, `/{id}/rsvp`, check-in).
class EventsRepository {
  Future<List<Map<String, dynamic>>> list() async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.eventsAdmin);
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> store({
    required String title,
    required String description,
    required String eventType,
    required String startsAt,
    required String endsAt,
    required String venue,
    int? capacity,
  }) async {
    try {
      final Response<dynamic> r = await ApiClient.dio.post<dynamic>(
        ApiEndpoints.eventsAdmin,
        data: <String, dynamic>{
          'title': title,
          'description': description,
          'event_type': eventType,
          'starts_at': startsAt,
          'ends_at': endsAt,
          'venue': venue,
          if (capacity != null) 'capacity': capacity,
        },
      );
      return unwrapMap(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<void> rsvp(int eventId) async {
    try {
      await ApiClient.dio.post<dynamic>(ApiEndpoints.eventRsvp(eventId));
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> rsvps(int eventId) async {
    try {
      final Response<dynamic> r =
          await ApiClient.dio.get<dynamic>(ApiEndpoints.eventRsvps(eventId));
      return unwrapList(r.data);
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}
