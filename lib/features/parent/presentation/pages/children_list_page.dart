import 'package:flutter/material.dart';

import '../../../../core/widgets/module_list_page.dart';
import '../../data/parent_repository.dart';
import 'child_detail_page.dart';

/// Daftar anak wali → 7 tab detail per anak (docs §parent §2).
/// Backend: `GET /parent/children`.
class ChildrenListPage extends StatelessWidget {
  const ChildrenListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ParentRepository repo = ParentRepository();
    return ModuleListPage(
      title: 'Anak Saya',
      loader: repo.children,
      emptyText: 'Belum ada data anak. Hubungi TU sekolah.',
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num?)?.toInt() ??
            (e['student_id'] as num?)?.toInt() ??
            0;
        final String name =
            e['name']?.toString() ?? e['student_name']?.toString() ?? '-';
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?'),
            ),
            title: Text(name),
            subtitle: Text(
                '${e['class'] ?? e['class_name'] ?? ''} • NIS ${e['nis'] ?? '-'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(c).push(
              MaterialPageRoute<void>(
                builder: (_) =>
                    ChildDetailPage(studentId: id, studentName: name),
              ),
            ),
          ),
        );
      },
    );
  }
}
