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
        // Backend returns the Student model with `user` + `class_section`
        // relations (no flat name/nis keys).
        final Map<String, dynamic>? user = e['user'] is Map
            ? Map<String, dynamic>.from(e['user'] as Map)
            : null;
        final String name = user?['name']?.toString() ??
            e['name']?.toString() ??
            e['student_name']?.toString() ??
            'Anak $id';
        final Map<String, dynamic>? section = e['class_section'] is Map
            ? Map<String, dynamic>.from(e['class_section'] as Map)
            : (e['classSection'] is Map
                ? Map<String, dynamic>.from(e['classSection'] as Map)
                : null);
        final String rombel = section?['name']?.toString() ??
            e['class']?.toString() ??
            e['class_name']?.toString() ??
            '';
        final String nis =
            e['admission_no']?.toString() ?? e['nis']?.toString() ?? '-';
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                  name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?'),
            ),
            title: Text(name),
            subtitle: Text('${rombel.isNotEmpty ? '$rombel • ' : ''}NIS $nis'),
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
