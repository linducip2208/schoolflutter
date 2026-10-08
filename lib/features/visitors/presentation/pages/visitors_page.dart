import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/visitors_repository.dart';

/// Visitor: check-in, approve, check-out.
/// Backend: `/visitors*` (`visitor.view|manage`).
class VisitorsPage extends StatelessWidget {
  const VisitorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final VisitorsRepository repo = VisitorsRepository();
    return ModuleListPage(
      title: 'Tamu',
      loader: repo.active,
      emptyText: 'Tidak ada tamu aktif.',
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Check-in Tamu',
          fields: const <FormFieldDef>[
            FormFieldDef(key: 'name', label: 'Nama'),
            FormFieldDef(key: 'purpose', label: 'Keperluan'),
            FormFieldDef(key: 'phone', label: 'No. HP'),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.checkIn(
            name: v['name']!,
            purpose: v['purpose']!,
            phone: v['phone'],
          ),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        final String status = e['status']?.toString() ?? '-';
        return Card(
          child: ListTile(
            leading: const Icon(Icons.badge_outlined),
            title: Text(e['name']?.toString() ?? '-'),
            subtitle: Text(
                '${e['purpose'] ?? '-'} • ${e['check_in_at'] ?? e['created_at'] ?? '-'}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (status == 'pending')
                  IconButton(
                    tooltip: 'Setujui',
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () async {
                      await runMutation(c, () => repo.approve(id));
                    },
                  ),
                IconButton(
                  tooltip: 'Check-out',
                  icon: const Icon(Icons.logout_outlined),
                  onPressed: () async {
                    await runMutation(c, () => repo.checkOut(id));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
