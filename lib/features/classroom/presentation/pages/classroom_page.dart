import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/api/upload_repository.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../directory/data/directory_repository.dart';
import '../../data/classroom_repository.dart';

/// Kelas online: pilih rombel → materi (lessons) → tugas (assignments)
/// → kumpul/nilai. Backend mewajibkan `class_section_id` lalu
/// `lesson_id` (tanpa itu 422).
class ClassroomPage extends StatefulWidget {
  const ClassroomPage({super.key});

  @override
  State<ClassroomPage> createState() => _ClassroomPageState();
}

class _ClassroomPageState extends State<ClassroomPage> {
  final ClassroomRepository _repo = ClassroomRepository();
  final DirectoryRepository _dir = DirectoryRepository();
  List<Map<String, dynamic>> _sections = const <Map<String, dynamic>>[];
  int? _sectionId;
  int? _lessonId;
  String? _lessonTitle;
  late Future<List<Map<String, dynamic>>> _future;

  String get _role => context.read<AuthBloc>().state.user?.role ?? 'student';

  bool get _canManage =>
      _role == 'admin' ||
      _role == 'school_admin' ||
      _role == 'super_admin' ||
      _role == 'teacher' ||
      _role == 'homeroom_teacher';

  @override
  void initState() {
    super.initState();
    _future = _loadSections().then((_) => _loadLessons());
  }

  Future<void> _loadSections() async {
    try {
      _sections = await _dir.classSections();
    } catch (_) {
      _sections = const <Map<String, dynamic>>[];
    }
    if (_sections.isNotEmpty) {
      _sectionId ??= (_sections.first['id'] as num?)?.toInt();
    }
  }

  Future<List<Map<String, dynamic>>> _loadLessons() {
    if (_sectionId == null) {
      return Future<List<Map<String, dynamic>>>.value(
          const <Map<String, dynamic>>[]);
    }
    return _repo.lessons(classSectionId: _sectionId!);
  }

  Future<List<Map<String, dynamic>>> _loadAssignments() {
    if (_lessonId == null) {
      return Future<List<Map<String, dynamic>>>.value(
          const <Map<String, dynamic>>[]);
    }
    return _repo.assignments(lessonId: _lessonId!);
  }

  void _reload() => setState(() => _future = _loadLessons());

  String _sectionLabel(Map<String, dynamic> s) {
    final dynamic room = s['class_room'];
    final dynamic sec = s['section'];
    final String r = room is Map ? (room['name']?.toString() ?? '') : '';
    final String t = sec is Map ? (sec['name']?.toString() ?? '') : '';
    final String label = '$r $t'.trim();
    return label.isEmpty ? 'Rombel ${s['id']}' : label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_lessonId == null ? 'Kelas' : (_lessonTitle ?? 'Tugas')),
        leading: _lessonId == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() {
                  _lessonId = null;
                  _lessonTitle = null;
                  _future = _loadLessons();
                }),
              ),
      ),
      floatingActionButton: _canManage && _lessonId == null
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
      body: Column(
        children: <Widget>[
          if (_lessonId == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: DropdownButtonFormField<int>(
                initialValue: _sectionId,
                decoration: const InputDecoration(labelText: 'Rombel'),
                items: <DropdownMenuItem<int>>[
                  for (final Map<String, dynamic> s in _sections)
                    DropdownMenuItem<int>(
                      value: (s['id'] as num?)?.toInt(),
                      child: Text(_sectionLabel(s)),
                    ),
                ],
                onChanged: (int? id) => setState(() {
                  _sectionId = id;
                  _future = _loadLessons();
                }),
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
                  return AppError(
                      message: '${snap.error}',
                      onRetry: () => setState(() => _future = _lessonId == null
                          ? _loadLessons()
                          : _loadAssignments()));
                }
                final List<Map<String, dynamic>> list =
                    snap.data ?? <Map<String, dynamic>>[];
                if (list.isEmpty) {
                  return AppEmpty(
                      title: _lessonId == null
                          ? 'Belum ada materi'
                          : 'Belum ada tugas');
                }
                return RefreshIndicator(
                  onRefresh: () async => setState(() => _future =
                      _lessonId == null ? _loadLessons() : _loadAssignments()),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext c, int i) {
                      final Map<String, dynamic> a = list[i];
                      if (_lessonId == null) {
                        return _LessonTile(
                          lesson: a,
                          canManage: _canManage,
                          onOpen: () => setState(() {
                            _lessonId = (a['id'] as num).toInt();
                            _lessonTitle = a['title']?.toString() ?? 'Tugas';
                            _future = _loadAssignments();
                          }),
                          onAddMaterial: () =>
                              _addMaterial(context, (a['id'] as num).toInt()),
                        );
                      }
                      return _AssignmentTile(
                        assignment: a,
                        canGrade: _canManage,
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

  /// Tambah materi: link/video langsung, file via upload dulu.
  Future<void> _addMaterial(BuildContext context, int lessonId) async {
    final Map<String, String>? v = await showFormDialog(
      context,
      title: 'Materi Baru',
      fields: const <FormFieldDef>[
        FormFieldDef(key: 'title', label: 'Judul'),
        FormFieldDef(
            key: 'type',
            label: 'Tipe',
            options: <String>['file', 'link', 'video']),
        FormFieldDef(
            key: 'url',
            label: 'URL (kosongkan bila upload file)',
            optional: true),
      ],
    );
    if (v == null || !context.mounted) return;
    String url = v['url']!;
    if (url.isEmpty) {
      if (v['type'] != 'file') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Isi URL untuk tipe link/video.')),
        );
        return;
      }
      final FilePickerResult? picked = await FilePicker.platform.pickFiles();
      final String? path = picked?.files.single.path;
      if (path == null || !context.mounted) return;
      try {
        final Map<String, dynamic> up = await UploadRepository().upload(
          file: File(path),
          purpose: 'classroom_material',
        );
        url = (up['path'] ?? up['url'] ?? '').toString();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        return;
      }
      if (url.isEmpty || !context.mounted) return;
    }
    await runMutation(
      context,
      () => _repo.storeMaterial(
        lessonId: lessonId,
        title: v['title']!,
        type: v['type']!,
        url: url,
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.lesson,
    required this.canManage,
    required this.onOpen,
    required this.onAddMaterial,
  });

  final Map<String, dynamic> lesson;
  final bool canManage;
  final VoidCallback onOpen;
  final Future<void> Function() onAddMaterial;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: const Icon(Icons.menu_book_outlined, color: AppColors.primary),
        title: Text(lesson['title'] as String? ?? '-'),
        subtitle: Text(
            '${lesson['subject'] is Map ? (lesson['subject'] as Map)['name'] ?? '' : (lesson['subject_name'] ?? '')}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (canManage)
              IconButton(
                tooltip: 'Tambah materi',
                icon: const Icon(Icons.attach_file_outlined, size: 20),
                onPressed: onAddMaterial,
              ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onOpen,
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  const _AssignmentTile({required this.assignment, required this.canGrade});

  final Map<String, dynamic> assignment;
  final bool canGrade;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading:
            const Icon(Icons.assignment_outlined, color: AppColors.primary),
        title: Text(assignment['title'] as String? ?? '-'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (assignment['due_date'] != null)
              Text(
                'Tenggat: ${DateFormatter.dateTime(DateTime.parse(assignment['due_date'] as String))}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openSubmissions(
            context, assignment, canGrade, assignment['id'] as num?),
      ),
    );
  }

  Future<void> _openSubmissions(BuildContext context,
      Map<String, dynamic> assignment, bool canGrade, num? rawId) async {
    if (rawId == null) return;
    final ClassroomRepository repo = ClassroomRepository();
    final int id = rawId.toInt();
    List<Map<String, dynamic>> items = const <Map<String, dynamic>>[];
    String? error;
    try {
      items = await repo.submissions(id);
    } catch (e) {
      error = e.toString();
    }
    if (!context.mounted) return;
    final bool isStudent = !canGrade;
    await showDialog<void>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: Text('${assignment['title'] ?? 'Tugas'}'),
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
                          if (isStudent)
                            FilledButton.icon(
                              icon: const Icon(Icons.upload_outlined, size: 18),
                              label: const Text('Kumpulkan jawaban'),
                              onPressed: () async {
                                final Map<String, String>? v =
                                    await showFormDialog(
                                  d,
                                  title: 'Kumpulkan',
                                  fields: const <FormFieldDef>[
                                    FormFieldDef(
                                        key: 'answer', label: 'Jawaban'),
                                  ],
                                );
                                if (v == null || !d.mounted) return;
                                final bool ok = await runMutation(
                                  d,
                                  () => repo.submitAssignment(id,
                                      answer: v['answer']),
                                );
                                if (ok && d.mounted) {
                                  Navigator.of(d).pop();
                                }
                              },
                            ),
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
}
