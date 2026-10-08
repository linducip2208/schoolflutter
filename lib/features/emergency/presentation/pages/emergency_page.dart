import 'package:flutter/material.dart';

import '../../../../core/widgets/module_list_page.dart';
import '../../data/emergency_repository.dart';

/// Tombol darurat + kontak + riwayat.
/// Backend: `/emergency/panic|recent|contacts`.
class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final EmergencyRepository repo = EmergencyRepository();
    return Scaffold(
      appBar: AppBar(title: const Text('Darurat')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              minimumSize: const Size(double.infinity, 56),
            ),
            icon: const Icon(Icons.sos_outlined),
            label: const Text('PANIC BUTTON'),
            onPressed: () async {
              final bool ok = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext d) => AlertDialog(
                      title: const Text('Kirim sinyal darurat?'),
                      content: const Text(
                          'Sekolah akan menerima lokasi dan identitas Anda.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(d).pop(false),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(d).pop(true),
                          child: const Text('Kirim'),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (ok && context.mounted) {
                await runMutation(context, () => repo.panic());
              }
            },
          ),
          const SizedBox(height: 16),
          Text('Kontak Darurat',
              style: Theme.of(context).textTheme.titleSmall),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: repo.contacts(),
            builder: (BuildContext c,
                AsyncSnapshot<List<Map<String, dynamic>>> snap) {
              final List<Map<String, dynamic>> items =
                  snap.data ?? const <Map<String, dynamic>>[];
              if (!snap.hasData) {
                return const Padding(
                    padding: EdgeInsets.all(8),
                    child: LinearProgressIndicator());
              }
              if (items.isEmpty) {
                return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Belum ada kontak darurat.'));
              }
              return Column(
                children: <Widget>[
                  for (final Map<String, dynamic> e in items)
                    Card(
                      child: ListTile(
                        dense: true,
                        leading: const Icon(Icons.phone_outlined),
                        title: Text(e['name']?.toString() ?? '-'),
                        subtitle:
                            Text(e['phone']?.toString() ?? '-'),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
