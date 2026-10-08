import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/events_repository.dart';

/// Event sekolah: admin buat, semua peran RSVP.
/// Backend: `GET /events` (adminList), `POST /events`
/// (`event.manage`), `/{id}/rsvp`.
class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EventsRepository repo = EventsRepository();
    final String role =
        context.watch<AuthBloc>().state.user?.role ?? 'student';
    final bool canManage = role == 'admin' ||
        role == 'school_admin' ||
        role == 'super_admin';
    return ModuleListPage(
      title: 'Event Sekolah',
      loader: repo.list,
      emptyText: 'Belum ada event.',
      onCreate: canManage
          ? () async {
              final Map<String, String>? v = await showFormDialog(
                context,
                title: 'Event Baru',
                fields: const <FormFieldDef>[
                  FormFieldDef(key: 'title', label: 'Judul'),
                  FormFieldDef(key: 'description', label: 'Deskripsi'),
                  FormFieldDef(
                      key: 'event_type',
                      label: 'Tipe',
                      options: <String>[
                        'parent_meeting',
                        'field_trip',
                        'festival',
                        'competition',
                        'workshop',
                        'seminar'
                      ]),
                  FormFieldDef(key: 'starts_at', label: 'Mulai (YYYY-MM-DD)'),
                  FormFieldDef(key: 'ends_at', label: 'Selesai (YYYY-MM-DD)'),
                  FormFieldDef(key: 'venue', label: 'Tempat'),
                  FormFieldDef(key: 'capacity', label: 'Kapasitas', isNumber: true),
                ],
              );
              if (v == null || !context.mounted) return;
              await runMutation(
                context,
                () => repo.store(
                  title: v['title']!,
                  description: v['description']!,
                  eventType: v['event_type']!,
                  startsAt: v['starts_at']!,
                  endsAt: v['ends_at']!,
                  venue: v['venue']!,
                  capacity: int.tryParse(v['capacity'] ?? ''),
                ),
              );
            }
          : null,
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.event_outlined),
            title: Text(e['title']?.toString() ?? '-'),
            subtitle: Text(
                '${e['event_type'] ?? '-'} • ${e['starts_at'] ?? '-'} • ${e['venue'] ?? '-'}'),
            trailing: canManage
                ? IconButton(
                    tooltip: 'RSVP list',
                    icon: const Icon(Icons.people_outline),
                    onPressed: () => _showRsvps(c, repo, id),
                  )
                : FilledButton.tonal(
                    onPressed: () async {
                      await runMutation(c, () => repo.rsvp(id));
                    },
                    child: const Text('RSVP'),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _showRsvps(
      BuildContext c, EventsRepository repo, int id) async {
    List<Map<String, dynamic>> items = const <Map<String, dynamic>>[];
    String? error;
    try {
      items = await repo.rsvps(id);
    } catch (err) {
      error = err.toString();
    }
    if (!c.mounted) return;
    await showDialog<void>(
      context: c,
      builder: (BuildContext d) => AlertDialog(
        title: const Text('RSVP'),
        content: SizedBox(
          width: double.maxFinite,
          child: error != null
              ? Text(error)
              : items.isEmpty
                  ? const Text('Belum ada RSVP.')
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final Map<String, dynamic> r in items)
                            ListTile(
                              dense: true,
                              title: Text(
                                  r['name']?.toString() ?? 'ID ${r['id']}'),
                              subtitle: Text(
                                  r['status']?.toString() ?? '-'),
                            ),
                        ],
                      ),
                    ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(d).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
