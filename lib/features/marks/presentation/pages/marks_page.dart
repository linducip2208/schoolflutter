import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../parent/data/parent_repository.dart';
import '../../data/marks_repository.dart';

/// Nilai: siswa (milik sendiri), wali (per anak + rapor PDF),
/// guru/admin (per ID siswa + rapor PDF).
/// Backend: `/marks/me|student/{id}`, `/report-cards/*`.
class MarksPage extends StatefulWidget {
  const MarksPage({super.key});

  @override
  State<MarksPage> createState() => _MarksPageState();
}

class _MarksPageState extends State<MarksPage> {
  final MarksRepository _repo = MarksRepository();
  int? _studentId;
  List<Map<String, dynamic>> _children = const <Map<String, dynamic>>[];
  late Future<List<Map<String, dynamic>>> _future;

  String get _role => context.read<AuthBloc>().state.user?.role ?? 'student';

  @override
  void initState() {
    super.initState();
    // Parent has no /marks/me row (backend looks up student by user_id):
    // start empty, fill once children load.
    _future = _role == 'parent'
        ? Future<List<Map<String, dynamic>>>.value(
            const <Map<String, dynamic>>[])
        : _repo.mine();
    if (_role == 'parent') {
      ParentRepository().children().then((List<Map<String, dynamic>> v) {
        if (!mounted) return;
        setState(() {
          _children = v;
          if (v.isNotEmpty) {
            _studentId = (v.first['id'] as num?)?.toInt() ??
                (v.first['student_id'] as num?)?.toInt();
            _future = _load();
          }
        });
      }).catchError((Object _) {});
    }
  }

  Future<List<Map<String, dynamic>>> _load() {
    if (_role == 'student') return _repo.mine();
    if (_studentId != null) return _repo.byStudent(_studentId!);
    return _repo.mine();
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    final bool needPicker =
        _role == 'parent' || _role == 'teacher' || _role == 'admin';
    return Scaffold(
      appBar: AppBar(title: const Text('Nilai')),
      body: Column(
        children: <Widget>[
          if (_role == 'parent' && _children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: DropdownButtonFormField<int>(
                initialValue: _studentId,
                decoration: const InputDecoration(labelText: 'Anak'),
                items: <DropdownMenuItem<int>>[
                  for (final Map<String, dynamic> e in _children)
                    DropdownMenuItem<int>(
                      value: (e['id'] as num?)?.toInt() ??
                          (e['student_id'] as num?)?.toInt(),
                      child: Text(e['name']?.toString() ??
                          e['student_name']?.toString() ??
                          '-'),
                    ),
                ],
                onChanged: (int? v) => setState(() {
                  _studentId = v;
                  _future = _load();
                }),
              ),
            ),
          if ((_role == 'teacher' || _role == 'admin') && _studentId == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: <Widget>[
                  const Expanded(
                      child: Text('Pilih siswa via Direktori Siswa.')),
                  if (needPicker && _role != 'parent')
                    TextButton(
                      onPressed: () async {
                        final Map<String, String>? v = await showFormDialog(
                          context,
                          title: 'Lihat Nilai Siswa',
                          fields: const <FormFieldDef>[
                            FormFieldDef(
                                key: 'student_id',
                                label: 'ID Siswa',
                                isNumber: true),
                          ],
                        );
                        if (v == null || !context.mounted) return;
                        setState(() {
                          _studentId = int.parse(v['student_id']!);
                          _future = _load();
                        });
                      },
                      child: const Text('Pilih'),
                    ),
                ],
              ),
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
                return RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      if (list.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: Text('Belum ada nilai.')),
                        ),
                      for (final Map<String, dynamic> m in list)
                        _MarkCard(mark: m),
                      if (_studentId != null)
                        _ReportSection(repo: _repo, studentId: _studentId!),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkCard extends StatelessWidget {
  const _MarkCard({required this.mark});
  final Map<String, dynamic> mark;

  @override
  Widget build(BuildContext context) {
    final num score = (mark['score'] as num?) ?? 0;
    final String grade = mark['grade'] as String? ?? '-';
    final Color color = score >= 80
        ? AppColors.success
        : score >= 65
            ? AppColors.warning
            : AppColors.danger;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(mark['subject'] as String? ?? '-',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(mark['exam_name'] as String? ?? '-',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(score.toStringAsFixed(0),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: color,
                      )),
                  Text(grade, style: TextStyle(fontSize: 11, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({required this.repo, required this.studentId});
  final MarksRepository repo;
  final int studentId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: repo.reportCards(studentId),
      builder:
          (BuildContext c, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
        if (!snap.hasData) {
          return const SizedBox.shrink();
        }
        if (snap.hasError) {
          return const SizedBox.shrink();
        }
        final List<Map<String, dynamic>> items =
            snap.data ?? const <Map<String, dynamic>>[];
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 8),
            Text('Rapor', style: Theme.of(context).textTheme.titleSmall),
            for (final Map<String, dynamic> r in items)
              Card(
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: Text(
                      'Semester ${r['semester_id'] ?? r['semester'] ?? '-'}'),
                  subtitle: Text('${r['status'] ?? '-'}'),
                  trailing: IconButton(
                    tooltip: 'Unduh PDF',
                    icon: const Icon(Icons.download_outlined),
                    onPressed: () async {
                      await runMutation(
                        c,
                        () => repo.downloadReportPdf((r['id'] as num).toInt()),
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
