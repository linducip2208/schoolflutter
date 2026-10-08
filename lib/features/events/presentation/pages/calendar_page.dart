import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';

/// Kalender akademik dari feed iCal.
/// Backend: `GET /calendar/ical` (text/calendar).
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Future<List<Map<String, String>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, String>>> _load() async {
    try {
      final Response<String> r = await ApiClient.dio.get<String>(
        ApiEndpoints.calendarIcal,
        options: Options(responseType: ResponseType.plain),
      );
      return _parse(r.data ?? '');
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  List<Map<String, String>> _parse(String ical) {
    final List<Map<String, String>> out = <Map<String, String>>[];
    Map<String, String>? cur;
    for (final String raw in ical.split(RegExp(r'\r?\n'))) {
      final String line = raw.trim();
      if (line == 'BEGIN:VEVENT') {
        cur = <String, String>{};
      } else if (line == 'END:VEVENT') {
        if (cur != null) out.add(cur);
        cur = null;
      } else if (cur != null) {
        final int i = line.indexOf(':');
        if (i > 0) cur[line.substring(0, i)] = line.substring(i + 1);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kalender Akademik')),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _future,
        builder: (BuildContext c,
            AsyncSnapshot<List<Map<String, String>>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
                padding: EdgeInsets.all(24), child: AppLoading());
          }
          if (snap.hasError) {
            return ListView(children: <Widget>[
              AppError(
                message: snap.error.toString(),
                onRetry: () => setState(() {
                  _future = _load();
                }),
              ),
            ]);
          }
          final List<Map<String, String>> items =
              snap.data ?? const <Map<String, String>>[];
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada agenda.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (BuildContext c, int i) {
              final Map<String, String> e = items[i];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.event_outlined),
                  title: Text(e['SUMMARY'] ?? '-'),
                  subtitle: Text(
                      '${e['DTSTART'] ?? '-'} → ${e['DTEND'] ?? '-'}${e['LOCATION'] != null ? '\n${e['LOCATION']}' : ''}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
