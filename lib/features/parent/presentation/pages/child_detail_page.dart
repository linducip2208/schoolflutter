import 'package:flutter/material.dart';

import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../achievements/data/achievements_repository.dart';
import '../../../discipline/data/discipline_repository.dart';
import '../../../medical/data/medical_repository.dart';
import '../../data/parent_repository.dart';

/// Detail anak — 7 tab wali (docs §parent §2-§3):
/// Overview, Absensi, Nilai, UKS, Disiplin, Prestasi, Konseling.
/// Tab konseling menampilkan catatan via wali kelas (tidak ada endpoint
/// anak-spesifik di API — ditampilkan jujur sebagai info, bukan data palsu).
class ChildDetailPage extends StatelessWidget {
  const ChildDetailPage(
      {super.key, required this.studentId, required this.studentName});
  final int studentId;
  final String studentName;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(studentName),
          bottom: const TabBar(
            isScrollable: true,
            tabs: <Widget>[
              Tab(text: 'Overview'),
              Tab(text: 'Absensi'),
              Tab(text: 'Nilai'),
              Tab(text: 'UKS'),
              Tab(text: 'Disiplin'),
              Tab(text: 'Prestasi'),
              Tab(text: 'Konseling'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            _OverviewTab(studentId: studentId, studentName: studentName),
            _SimpleListTab(
              title: 'Absensi',
              loader: () => ParentRepository().childAttendance(studentId),
              tile: (Map<String, dynamic> e) =>
                  '${e['date'] ?? e['created_at'] ?? '-'} • ${e['status'] ?? '-'}',
            ),
            _SimpleListTab(
              title: 'Nilai',
              loader: () => ParentRepository().childMarks(studentId),
              tile: (Map<String, dynamic> e) =>
                  '${e['subject'] ?? e['subject_name'] ?? '-'}: ${e['obtained_marks'] ?? e['score'] ?? '-'}',
            ),
            _SimpleListTab(
              title: 'UKS',
              loader: () => MedicalRepository().visits(studentId),
              tile: (Map<String, dynamic> e) =>
                  '${e['symptoms'] ?? '-'} • ${e['visited_at'] ?? e['created_at'] ?? '-'}',
            ),
            _DisciplineTab(studentId: studentId),
            _SimpleListTab(
              title: 'Prestasi',
              loader: () =>
                  AchievementsRepository().ofStudent(studentId),
              tile: (Map<String, dynamic> e) =>
                  '${e['title'] ?? '-'} • ${e['achieved_at'] ?? ''}',
            ),
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                  'Sesi konseling bersifat privat. Hubungi wali kelas/BK via Chat untuk menjadwalkan sesi.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.studentId, required this.studentName});
  final int studentId;
  final String studentName;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: ParentRepository().children(),
      builder: (BuildContext c,
          AsyncSnapshot<List<Map<String, dynamic>>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
              padding: EdgeInsets.all(24), child: AppLoading());
        }
        if (snap.hasError) {
          return ListView(children: <Widget>[
            AppError(message: snap.error.toString()),
          ]);
        }
        Map<String, dynamic>? me;
        for (final Map<String, dynamic> e in snap.data ?? const <Map<String, dynamic>>[]) {
          if ((e['id'] as num?)?.toInt() == studentId) me = e;
        }
        me ??= <String, dynamic>{'name': studentName};
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            for (final MapEntry<String, dynamic> e in me.entries)
              ListTile(
                dense: true,
                title: Text(e.key),
                subtitle: Text('${e.value}'),
              ),
          ],
        );
      },
    );
  }
}

class _DisciplineTab extends StatelessWidget {
  const _DisciplineTab({required this.studentId});
  final int studentId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DisciplineRepository().summary(studentId),
      builder:
          (BuildContext c, AsyncSnapshot<Map<String, dynamic>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
              padding: EdgeInsets.all(24), child: AppLoading());
        }
        if (snap.hasError) {
          return ListView(children: <Widget>[
            AppError(message: snap.error.toString()),
          ]);
        }
        final Map<String, dynamic> d = snap.data ?? const <String, dynamic>{};
        if (d.isEmpty) {
          return const Center(child: Text('Tidak ada catatan disiplin.'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            for (final MapEntry<String, dynamic> e in d.entries)
              ListTile(
                dense: true,
                title: Text(e.key),
                subtitle: Text('${e.value}'),
              ),
          ],
        );
      },
    );
  }
}

class _SimpleListTab extends StatelessWidget {
  const _SimpleListTab({
    required this.title,
    required this.loader,
    required this.tile,
  });
  final String title;
  final Future<List<Map<String, dynamic>>> Function() loader;
  final String Function(Map<String, dynamic>) tile;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: loader(),
      builder: (BuildContext c,
          AsyncSnapshot<List<Map<String, dynamic>>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
              padding: EdgeInsets.all(24), child: AppLoading());
        }
        if (snap.hasError) {
          return ListView(children: <Widget>[
            AppError(message: snap.error.toString()),
          ]);
        }
        final List<Map<String, dynamic>> items =
            snap.data ?? const <Map<String, dynamic>>[];
        if (items.isEmpty) {
          return Center(child: Text('Belum ada data $title.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (BuildContext c, int i) => Card(
            child: ListTile(dense: true, title: Text(tile(items[i]))),
          ),
        );
      },
    );
  }
}
