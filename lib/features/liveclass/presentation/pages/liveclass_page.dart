import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/liveclass_repository.dart';

/// Live class: jadwalkan (guru/admin), ikuti (siswa), mulai/selesai.
/// Backend: `/live-class/sessions*`. URL join dibuka di browser/aplikasi.
class LiveClassPage extends StatelessWidget {
  const LiveClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LiveClassRepository repo = LiveClassRepository();
    final String role = context.watch<AuthBloc>().state.user?.role ?? 'student';
    final bool canManage = role == 'admin' ||
        role == 'school_admin' ||
        role == 'super_admin' ||
        role == 'teacher';
    return ModuleListPage(
      title: 'Live Class',
      loader: repo.sessions,
      pagedLoader: ({required int page}) => repo.sessions(page: page),
      pageSize: 50,
      emptyText: 'Belum ada sesi live class.',
      onCreate: canManage
          ? () async {
              final Map<String, String>? v = await showFormDialog(
                context,
                title: 'Jadwalkan Sesi',
                fields: const <FormFieldDef>[
                  FormFieldDef(
                      key: 'class_section_id',
                      label: 'ID Rombel',
                      isNumber: true),
                  FormFieldDef(
                      key: 'subject_id', label: 'ID Mapel', isNumber: true),
                  FormFieldDef(key: 'topic', label: 'Topik'),
                  FormFieldDef(
                      key: 'scheduled_start',
                      label: 'Mulai (YYYY-MM-DD HH:MM)'),
                  FormFieldDef(
                      key: 'duration_minutes',
                      label: 'Durasi (menit)',
                      isNumber: true,
                      initial: '60'),
                ],
              );
              if (v == null || !context.mounted) return;
              await runMutation(
                context,
                () => repo.schedule(
                  classSectionId: int.parse(v['class_section_id']!),
                  subjectId: int.parse(v['subject_id']!),
                  topic: v['topic']!,
                  scheduledStart: v['scheduled_start']!,
                  durationMinutes: int.tryParse(v['duration_minutes']!) ?? 60,
                ),
              );
            }
          : null,
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.videocam_outlined),
            title: Text(e['topic']?.toString() ?? '-'),
            subtitle: Text(
                '${e['scheduled_start'] ?? e['start_at'] ?? '-'} • ${e['status'] ?? '-'}'),
            trailing: canManage
                ? PopupMenuButton<String>(
                    onSelected: (String v) async {
                      if (v == 'start') {
                        await runMutation(c, () => repo.start(id));
                      } else if (v == 'end') {
                        await runMutation(c, () => repo.end(id));
                      } else {
                        await _join(c, repo, id);
                      }
                    },
                    itemBuilder: (_) => const <PopupMenuItem<String>>[
                      PopupMenuItem<String>(
                          value: 'start', child: Text('Mulai')),
                      PopupMenuItem<String>(
                          value: 'end', child: Text('Selesai')),
                      PopupMenuItem<String>(
                          value: 'join', child: Text('Ikuti')),
                    ],
                  )
                : FilledButton.tonal(
                    onPressed: () => _join(c, repo, id),
                    child: const Text('Ikuti'),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _join(BuildContext c, LiveClassRepository repo, int id) async {
    try {
      final Map<String, dynamic> res = await repo.join(id);
      final String? url =
          (res['join_url'] ?? res['url'] ?? res['link'])?.toString();
      if (url == null || url.isEmpty) {
        if (c.mounted) {
          ScaffoldMessenger.of(c).showSnackBar(
            const SnackBar(content: Text('URL sesi belum tersedia.')),
          );
        }
        return;
      }
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (c.mounted) {
        ScaffoldMessenger.of(c)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
