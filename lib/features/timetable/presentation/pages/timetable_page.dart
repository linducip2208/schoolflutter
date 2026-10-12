import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/form_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/timetable_repository.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final TimetableRepository _repo = TimetableRepository();
  late Future<Map<String, List<Map<String, dynamic>>>> _future;

  static const List<String> _days = <String>[
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];
  static const List<String> _dayLabels = <String>[
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _days.length, vsync: this);
    final String role = context.read<AuthBloc>().state.user?.role ?? 'student';
    _future = _repo.mine(role: role);
    final int wd = DateTime.now().weekday;
    if (wd >= 1 && wd <= 6) _tab.index = wd - 1;
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _checkConflict(BuildContext context) async {
    final Map<String, String>? v = await showFormDialog(
      context,
      title: 'Cek Bentrok Slot',
      fields: const <FormFieldDef>[
        FormFieldDef(
            key: 'class_section_id', label: 'ID Rombel', isNumber: true),
        FormFieldDef(key: 'teacher_id', label: 'ID Guru', isNumber: true),
        FormFieldDef(
            key: 'day_of_week',
            label: 'Hari',
            options: <String>['1', '2', '3', '4', '5', '6', '7']),
        FormFieldDef(key: 'start_time', label: 'Mulai (HH:MM)', hint: '07:00'),
        FormFieldDef(key: 'end_time', label: 'Selesai (HH:MM)', hint: '08:30'),
      ],
    );
    if (v == null || !context.mounted) return;
    Map<String, dynamic>? res;
    String? error;
    try {
      res = await _repo.checkConflict(
        classSectionId: int.parse(v['class_section_id']!),
        teacherId: int.parse(v['teacher_id']!),
        dayOfWeek: int.parse(v['day_of_week']!),
        startTime: v['start_time']!,
        endTime: v['end_time']!,
      );
    } catch (e) {
      error = e.toString();
    }
    if (!context.mounted) return;
    final List<dynamic> conflicts =
        (res?['conflicts'] as List?) ?? const <dynamic>[];
    await showDialog<void>(
      context: context,
      builder: (BuildContext d) => AlertDialog(
        title: Text(error != null
            ? 'Gagal'
            : (res?['has_conflict'] == true ? 'Bentrok!' : 'Aman')),
        content: SizedBox(
          width: double.maxFinite,
          child: error != null
              ? Text(error)
              : conflicts.isEmpty
                  ? const Text('Tidak ada bentrok pada slot ini.')
                  : SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          for (final dynamic e in conflicts)
                            ListTile(
                              dense: true,
                              title: Text((e as Map)['title']?.toString() ??
                                  'Slot bentrok'),
                              subtitle: Text(
                                  '${e['day_of_week'] ?? ''} ${e['start_time'] ?? ''}-${e['end_time'] ?? ''}'),
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

  @override
  Widget build(BuildContext context) {
    final String role = context.watch<AuthBloc>().state.user?.role ?? 'student';
    final bool canManage =
        role == 'admin' || role == 'school_admin' || role == 'super_admin';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Pelajaran'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: <Widget>[for (final String l in _dayLabels) Tab(text: l)],
        ),
        actions: canManage
            ? <Widget>[
                IconButton(
                  tooltip: 'Cek bentrok slot',
                  icon: const Icon(Icons.compare_arrows_outlined),
                  onPressed: () => _checkConflict(context),
                ),
              ]
            : null,
      ),
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _future,
        builder: (BuildContext c,
            AsyncSnapshot<Map<String, List<Map<String, dynamic>>>> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }
          if (snap.hasError) {
            return AppError(
              message: '${snap.error}',
              onRetry: () {
                final String role =
                    context.read<AuthBloc>().state.user?.role ?? 'student';
                setState(() => _future = _repo.mine(role: role));
              },
            );
          }
          final Map<String, List<Map<String, dynamic>>> data =
              snap.data ?? <String, List<Map<String, dynamic>>>{};
          return TabBarView(
            controller: _tab,
            children: <Widget>[
              for (final String day in _days)
                _DayList(items: data[day] ?? const <Map<String, dynamic>>[]),
            ],
          );
        },
      ),
    );
  }
}

class _DayList extends StatelessWidget {
  const _DayList({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const AppEmpty(title: 'Tidak ada jadwal');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext c, int i) {
        final Map<String, dynamic> s = items[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(s['start'] as String? ?? '--:--',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(s['end'] as String? ?? '--:--',
                          style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context).hintColor)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(s['subject'] as String? ?? '-',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        '${s['teacher'] ?? '-'} • ${s['room'] ?? '-'}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
