import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/admission_repository.dart';

/// Admisi: statistik + daftar + tambah + ubah status + enroll.
/// Backend: `/admission*` (status: enquiry, applied, enrolled, rejected).
class AdmissionPage extends StatefulWidget {
  const AdmissionPage({super.key});

  @override
  State<AdmissionPage> createState() => _AdmissionPageState();
}

class _AdmissionPageState extends State<AdmissionPage> {
  final AdmissionRepository _repo = AdmissionRepository();
  late Future<List<Map<String, dynamic>>> _future = _fetch();

  Future<List<Map<String, dynamic>>> _fetch() => _repo.list();

  void _reload() => setState(() => _future = _fetch());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pendaftaran Siswa Baru')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Pendaftar'),
        onPressed: () async {
          final Map<String, String>? v = await showFormDialog(
            context,
            title: 'Pendaftar Baru',
            fields: const <FormFieldDef>[
              FormFieldDef(key: 'student_name', label: 'Nama calon siswa'),
              FormFieldDef(key: 'phone', label: 'No. HP'),
            ],
          );
          if (v == null || !context.mounted) return;
          final bool ok = await runMutation(
            context,
            () => _repo.store(
                studentName: v['student_name']!, phone: v['phone']!),
          );
          if (ok) _reload();
        },
      ),
      body: Column(
        children: <Widget>[
          FutureBuilder<Map<String, dynamic>>(
            future: _repo.stats(),
            builder:
                (BuildContext c, AsyncSnapshot<Map<String, dynamic>> snap) {
              if (!snap.hasData) return const SizedBox.shrink();
              final Map<String, dynamic> s = snap.data!;
              if (s.isEmpty) return const SizedBox.shrink();
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: <Widget>[
                    for (final MapEntry<String, dynamic> e in s.entries)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(
                          label: Text('${_label(e.key)}: ${e.value}'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (BuildContext c,
                  AsyncSnapshot<List<Map<String, dynamic>>> snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const AppLoading();
                }
                if (snap.hasError) {
                  return AppError(message: '${snap.error}', onRetry: _reload);
                }
                final List<Map<String, dynamic>> list =
                    snap.data ?? <Map<String, dynamic>>[];
                if (list.isEmpty) {
                  return const AppEmpty(title: 'Belum ada pendaftar');
                }
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext c, int i) {
                      final Map<String, dynamic> e = list[i];
                      final String status = e['status'] as String? ?? 'enquiry';
                      final int id = (e['id'] as num).toInt();
                      return _AdmissionTile(
                        entry: e,
                        status: status,
                        onAction: (String v) => _onAction(c, id, v),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAction(BuildContext c, int id, String v) async {
    if (v == 'enroll') {
      final Map<String, String>? f = await showFormDialog(
        c,
        title: 'Enroll ke Rombel',
        fields: const <FormFieldDef>[
          FormFieldDef(
              key: 'class_section_id', label: 'ID Rombel', isNumber: true),
        ],
      );
      if (f == null || !c.mounted) return;
      final bool ok = await runMutation(
        c,
        () => _repo.enroll(id, int.parse(f['class_section_id']!)),
      );
      if (ok) _reload();
    } else {
      final bool ok = await runMutation(c, () => _repo.updateStatus(id, v));
      if (ok) _reload();
    }
  }

  String _label(String s) => switch (s) {
        'enquiry' => 'Baru',
        'applied' => 'Diproses',
        'enrolled' => 'Diterima',
        'rejected' => 'Ditolak',
        _ => s,
      };

  Color _color(String s) => switch (s) {
        'enrolled' => AppColors.success,
        'rejected' => AppColors.danger,
        'applied' => AppColors.info,
        _ => AppColors.warning,
      };
}

class _AdmissionTile extends StatelessWidget {
  const _AdmissionTile({
    required this.entry,
    required this.status,
    required this.onAction,
  });

  final Map<String, dynamic> entry;
  final String status;
  final ValueChanged<String> onAction;

  Color _color(String s) => switch (s) {
        'enrolled' => AppColors.success,
        'rejected' => AppColors.danger,
        'applied' => AppColors.info,
        _ => AppColors.warning,
      };

  String _label(String s) => switch (s) {
        'enquiry' => 'Baru',
        'applied' => 'Diproses',
        'enrolled' => 'Diterima',
        'rejected' => 'Ditolak',
        _ => s,
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: const Icon(Icons.person_outline, color: AppColors.primary),
        ),
        title: Text(entry['student_name'] as String? ?? '-'),
        subtitle: Text(
            '${entry['phone'] ?? '-'} • ${entry['class_applying'] ?? '-'}'),
        trailing: PopupMenuButton<String>(
          onSelected: onAction,
          itemBuilder: (_) => const <PopupMenuItem<String>>[
            PopupMenuItem<String>(value: 'applied', child: Text('Diproses')),
            PopupMenuItem<String>(value: 'rejected', child: Text('Tolak')),
            PopupMenuItem<String>(
                value: 'enroll', child: Text('Enroll ke rombel')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _color(status).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(_label(status),
                style: TextStyle(
                    color: _color(status),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}
