import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/career_repository.dart';

/// Karier/BKK: magang + asesmen minat-bakat.
/// Backend: `/career/*`.
class CareerPage extends StatelessWidget {
  const CareerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CareerRepository repo = CareerRepository();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Karier & Magang'),
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: 'Magang'), Tab(text: 'Asesmen')],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ModuleListPage(
              title: 'Magang',
              loader: repo.internships,
              pagedLoader: ({required int page}) =>
                  repo.internships(page: page),
              pageSize: 50,
              emptyText: 'Belum ada data magang.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Magang Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(
                        key: 'student_id', label: 'ID Siswa', isNumber: true),
                    FormFieldDef(key: 'company_name', label: 'Perusahaan'),
                    FormFieldDef(key: 'position', label: 'Posisi'),
                    FormFieldDef(
                        key: 'start_date', label: 'Mulai (YYYY-MM-DD)'),
                    FormFieldDef(
                        key: 'end_date', label: 'Selesai (YYYY-MM-DD)'),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.storeInternship(
                    studentId: int.parse(v['student_id']!),
                    company: v['company_name']!,
                    position: v['position']!,
                    startDate: v['start_date']!,
                    endDate: v['end_date']!,
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
                child: ListTile(
                  leading: const Icon(Icons.work_outline),
                  title: Text(
                      '${e['position'] ?? '-'} @ ${e['company_name'] ?? e['company'] ?? '-'}'),
                  subtitle: Text(
                      'Siswa ${e['student_id'] ?? '-'} • Status ${e['status'] ?? '-'}'),
                  trailing: IconButton(
                    tooltip: 'Log aktivitas',
                    icon: const Icon(Icons.note_add_outlined),
                    onPressed: () async {
                      final Map<String, String>? v = await showFormDialog(
                        c,
                        title: 'Aktivitas Harian',
                        fields: const <FormFieldDef>[
                          FormFieldDef(key: 'activity', label: 'Aktivitas'),
                        ],
                      );
                      if (v == null || !c.mounted) return;
                      await runMutation(
                        c,
                        () => repo.logActivity(
                            (e['id'] as num).toInt(), v['activity']!),
                      );
                    },
                  ),
                ),
              ),
            ),
            _AssessmentTab(repo: repo),
          ],
        ),
      ),
    );
  }
}

class _AssessmentTab extends StatefulWidget {
  const _AssessmentTab({required this.repo});
  final CareerRepository repo;

  @override
  State<_AssessmentTab> createState() => _AssessmentTabState();
}

class _AssessmentTabState extends State<_AssessmentTab> {
  final TextEditingController _student = TextEditingController();
  Future<List<Map<String, dynamic>>>? _future;

  @override
  void dispose() {
    _student.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _student,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ID Siswa'),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              onPressed: () {
                final int? id = int.tryParse(_student.text.trim());
                if (id == null) return;
                setState(() {
                  _future = widget.repo.studentAssessments(id);
                });
              },
              child: const Text('Lihat'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Catat Asesmen'),
          onPressed: () async {
            final Map<String, String>? v = await showFormDialog(
              context,
              title: 'Asesmen Baru',
              fields: const <FormFieldDef>[
                FormFieldDef(
                    key: 'student_id', label: 'ID Siswa', isNumber: true),
                FormFieldDef(
                    key: 'test_type',
                    label: 'Tipe tes',
                    options: <String>[
                      'holland_riasec',
                      'mbti',
                      'cliftonstrengths',
                      'custom'
                    ]),
                FormFieldDef(
                    key: 'summary', label: 'Hasil ringkas (satu baris)'),
              ],
            );
            if (v == null || !context.mounted) return;
            await runMutation(
              context,
              () => widget.repo.recordAssessment(
                studentId: int.parse(v['student_id']!),
                testType: v['test_type']!,
                responses: <String>[v['summary']!],
                result: <String, dynamic>{'summary': v['summary']!},
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        if (_future != null)
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _future,
            builder: (BuildContext c,
                AsyncSnapshot<List<Map<String, dynamic>>> snap) {
              if (!snap.hasData) {
                return const LinearProgressIndicator();
              }
              if (snap.hasError) {
                return Text('${snap.error}');
              }
              final List<Map<String, dynamic>> items =
                  snap.data ?? const <Map<String, dynamic>>[];
              if (items.isEmpty) {
                return const Text('Belum ada asesmen.');
              }
              return Column(
                children: <Widget>[
                  for (final Map<String, dynamic> e in items)
                    Card(
                      child: ListTile(
                        dense: true,
                        title: Text(e['test_type']?.toString() ?? '-'),
                        subtitle:
                            Text('${e['taken_at'] ?? e['created_at'] ?? '-'}'),
                      ),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}
