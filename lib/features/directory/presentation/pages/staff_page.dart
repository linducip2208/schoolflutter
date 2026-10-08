import 'package:flutter/material.dart';

import '../../../../core/widgets/module_list_page.dart';
import '../../data/directory_repository.dart';

/// Direktori staf/guru (`staff.view`).
/// Backend: `GET /directory/staff`.
class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DirectoryRepository repo = DirectoryRepository();
    return ModuleListPage(
      title: 'Staf & Guru',
      loader: () => repo.staff(),
      emptyText: 'Belum ada data staf.',
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final Map<String, dynamic>? user = e['user'] is Map
            ? Map<String, dynamic>.from(e['user'] as Map)
            : null;
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text(
                  ((user?['name'] ?? '?') as String).substring(0, 1).toUpperCase()),
            ),
            title: Text(user?['name']?.toString() ?? 'ID ${e['id']}'),
            subtitle: Text(
                '${e['designation'] ?? e['department'] ?? '-'} • ${e['employee_id'] ?? '-'}'),
          ),
        );
      },
    );
  }
}
