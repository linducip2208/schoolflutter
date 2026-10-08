import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/ai_admin_repository.dart';

/// AI provider BYOK (`/admin/ai-providers`).
/// Backend: `AiController` (`role:admin`).
/// Format: openai_compatible, anthropic_format, gemini_format, image_generic.
class AiProvidersPage extends StatelessWidget {
  const AiProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AiAdminRepository repo = AiAdminRepository();
    return ModuleListPage(
      title: 'AI Provider',
      loader: repo.providers,
      emptyText: 'Belum ada provider AI. Tambahkan API key sendiri.',
      onCreate: () async {
        final Map<String, String>? v = await showFormDialog(
          context,
          title: 'Provider Baru',
          fields: const <FormFieldDef>[
            FormFieldDef(key: 'name', label: 'Nama (mis. OpenAI)'),
            FormFieldDef(
                key: 'api_format',
                label: 'Format',
                options: <String>[
                  'openai_compatible',
                  'anthropic_format',
                  'gemini_format',
                  'image_generic'
                ]),
            FormFieldDef(key: 'base_url', label: 'Base URL', hint: 'https://api.openai.com/v1'),
            FormFieldDef(key: 'api_key', label: 'API Key'),
          ],
        );
        if (v == null || !context.mounted) return;
        await runMutation(
          context,
          () => repo.storeProvider(
            name: v['name']!,
            apiFormat: v['api_format']!,
            baseUrl: v['base_url']!,
            apiKey: v['api_key'],
          ),
        );
      },
      itemBuilder: (BuildContext c, Map<String, dynamic> e) {
        final int id = (e['id'] as num).toInt();
        return Card(
          child: ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: Text(e['name']?.toString() ?? '-'),
            subtitle: Text(
                '${e['api_format'] ?? '-'} • Aktif ${e['is_active'] ?? '-'}'),
            trailing: IconButton(
              tooltip: 'Hapus',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                await runMutation(c, () => repo.deleteProvider(id));
              },
            ),
          ),
        );
      },
    );
  }
}
