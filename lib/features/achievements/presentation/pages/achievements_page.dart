import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/achievements_repository.dart';

/// Prestasi: catat, verifikasi, leaderboard, badges.
/// Backend: `/achievements/*` (`achievement.manage` untuk catat).
class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AchievementsRepository repo = AchievementsRepository();
    final String role =
        context.watch<AuthBloc>().state.user?.role ?? 'student';
    final bool canManage = role == 'admin' ||
        role == 'school_admin' ||
        role == 'super_admin' ||
        role == 'teacher';
    return ModuleListPage(
      title: 'Prestasi',
      loader: repo.leaderboard,
      emptyText: 'Belum ada data prestasi.',
      onCreate: canManage
          ? () async {
              final Map<String, String>? v = await showFormDialog(
                context,
                title: 'Catat Prestasi',
                fields: const <FormFieldDef>[
                  FormFieldDef(
                      key: 'student_id', label: 'ID Siswa', isNumber: true),
                  FormFieldDef(
                      key: 'category_id', label: 'ID Kategori', isNumber: true),
                  FormFieldDef(key: 'title', label: 'Judul prestasi'),
                  FormFieldDef(
                      key: 'achieved_at', label: 'Tanggal (YYYY-MM-DD)'),
                  FormFieldDef(key: 'issuer', label: 'Penerbit'),
                ],
              );
              if (v == null || !context.mounted) return;
              await runMutation(
                context,
                () => repo.record(
                  studentId: int.parse(v['student_id']!),
                  categoryId: int.parse(v['category_id']!),
                  title: v['title']!,
                  achievedAt: v['achieved_at']!,
                  issuer: v['issuer'],
                ),
              );
            }
          : null,
      itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
        child: ListTile(
          leading: const Icon(Icons.emoji_events_outlined),
          title: Text(e['title']?.toString() ??
              e['name']?.toString() ??
              'ID ${e['id']}'),
          subtitle: Text(
              '${e['issuer'] ?? e['category'] ?? ''} • ${e['achieved_at'] ?? e['points'] ?? ''}'),
        ),
      ),
    );
  }
}
