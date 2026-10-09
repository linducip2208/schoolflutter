import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/classroom_repository.dart';

class ClassroomPage extends StatefulWidget {
  const ClassroomPage({super.key});

  @override
  State<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);
  final ClassroomRepository _repo = ClassroomRepository();
  late Future<List<Map<String, dynamic>>> _assignments;
  late Future<List<Map<String, dynamic>>> _materials;

  @override
  void initState() {
    super.initState();
    _assignments = _repo.assignments();
    _materials = _repo.lessons();
  }

  void _reload() {
    setState(() {
      _assignments = _repo.assignments();
      _materials = _repo.lessons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String role = context.watch<AuthBloc>().state.user?.role ?? 'student';
    final bool canManage = role == 'admin' ||
        role == 'school_admin' ||
        role == 'super_admin' ||
        role == 'teacher' ||
        role == 'homeroom_teacher';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelas'),
        bottom: TabBar(
          controller: _tab,
          tabs: const <Widget>[
            Tab(text: 'Tugas', icon: Icon(Icons.assignment_outlined)),
            Tab(text: 'Materi', icon: Icon(Icons.menu_book_outlined)),
          ],
        ),
      ),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Tugas'),
              onPressed: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Tugas Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(
                        key: 'lesson_id', label: 'ID Materi', isNumber: true),
                    FormFieldDef(key: 'title', label: 'Judul'),
                    FormFieldDef(
                        key: 'due_date', label: 'Tenggat (YYYY-MM-DD)'),
                  ],
                );
                if (v == null || !context.mounted) return;
                final bool ok = await runMutation(
                  context,
                  () => _repo.storeAssignment(
                    lessonId: int.parse(v['lesson_id']!),
                    title: v['title']!,
                    dueDate: v['due_date']!,
                  ),
                );
                if (ok) _reload();
              },
            )
          : null,
      body: TabBarView(
        controller: _tab,
        children: <Widget>[
          _List(
              future: _assignments,
              kind: 'assignment',
              onRefresh: _reload,
              canGrade: canManage),
          _List(future: _materials, kind: 'material', onRefresh: _reload),
        ],
      ),
    );
  }
}

Future<void> _openSubmissions(BuildContext context,
    Map<String, dynamic> assignment, bool canGrade) async {
  final ClassroomRepository repo = ClassroomRepository();
  final int id = (assignment['id'] as num).toInt();
  List<Map<String, dynamic>> items = const <Map<String, dynamic>>[];
  String? error;
  try {
    items = await repo.submissions(id);
  } catch (e) {
    error = e.toString();
  }
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (BuildContext d) => AlertDialog(
      title: Text('Submissions — ${assignment['title'] ?? ''}'),
      content: SizedBox(
        width: double.maxFinite,
        child: error != null
            ? Text(error)
            : items.isEmpty
                ? const Text('Belum ada submission.')
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        for (final Map<String, dynamic> s in items)
                          ListTile(
                            dense: true,
                            title: Text(
                                'Siswa ${s['student_id'] ?? '-'} • Nilai ${s['marks'] ?? '-'}'),
                            subtitle: Text('${s['feedback'] ?? ''}'),
                            trailing: canGrade
                                ? IconButton(
                                    tooltip: 'Nilai',
                                    icon: const Icon(Icons.grade_outlined),
                                    onPressed: () async {
                                      final Map<String, String>? v =
                                          await showFormDialog(
                                        d,
                                        title: 'Nilai Submission',
                                        fields: const <FormFieldDef>[
                                          FormFieldDef(
                                              key: 'marks',
                                              label: 'Nilai',
                                              isNumber: true),
                                          FormFieldDef(
                                              key: 'feedback',
                                              label: 'Feedback'),
                                        ],
                                      );
                                      if (v == null || !d.mounted) {
                                        return;
                                      }
                                      await runMutation(
                                        d,
                                        () => repo.gradeSubmission(
                                          (s['id'] as num).toInt(),
                                          int.parse(v['marks']!),
                                          feedback: v['feedback'],
                                        ),
                                      );
                                      if (d.mounted) {
                                        Navigator.of(d).pop();
                                      }
                                    },
                                  )
                                : null,
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

class _List extends StatelessWidget {
  const _List(
      {required this.future,
      required this.kind,
      required this.onRefresh,
      this.canGrade = false});

  final Future<List<Map<String, dynamic>>> future;
  final String kind;
  final VoidCallback onRefresh;
  final bool canGrade;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: future,
      builder:
          (BuildContext c, AsyncSnapshot<List<Map<String, dynamic>>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const AppLoading();
        }
        if (snap.hasError) {
          return AppError(message: '${snap.error}', onRetry: onRefresh);
        }
        final List<Map<String, dynamic>> list =
            snap.data ?? <Map<String, dynamic>>[];
        if (list.isEmpty) {
          return AppEmpty(
            title:
                kind == 'assignment' ? 'Belum ada tugas' : 'Belum ada materi',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => onRefresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (BuildContext c, int i) {
              final Map<String, dynamic> a = list[i];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: Icon(
                    kind == 'assignment'
                        ? Icons.assignment_outlined
                        : Icons.description_outlined,
                    color: AppColors.primary,
                  ),
                  title: Text(a['title'] as String? ?? '-'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 4),
                      Text(a['subject'] as String? ?? '-',
                          style: Theme.of(context).textTheme.bodySmall),
                      if (a['due_at'] != null) ...<Widget>[
                        const SizedBox(height: 4),
                        Text(
                          'Tenggat: ${DateFormatter.dateTime(DateTime.parse(a['due_at'] as String))}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: kind == 'assignment'
                      ? () => _openSubmissions(c, a, canGrade)
                      : null,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
