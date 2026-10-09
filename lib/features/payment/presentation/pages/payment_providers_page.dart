import 'package:flutter/material.dart';

import '../../../../core/widgets/form_dialog.dart';
import '../../../../core/widgets/module_list_page.dart';
import '../../data/payment_admin_repository.dart';

/// Payment provider BYOK + channel (`role:admin`).
/// Backend: `/admin/payment-providers*`, `/admin/payment-methods`.
/// Format: redirect_checkout, virtual_account, ewallet_deeplink, qris_dynamic.
class PaymentProvidersPage extends StatelessWidget {
  const PaymentProvidersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PaymentAdminRepository repo = PaymentAdminRepository();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Gateway'),
          bottom: const TabBar(
            tabs: <Widget>[Tab(text: 'Provider'), Tab(text: 'Channel')],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            ModuleListPage(
              title: 'Provider',
              loader: repo.providers,
              emptyText: 'Belum ada provider. Tambahkan Midtrans/Xendit/dll.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Provider Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(key: 'name', label: 'Nama (mis. Midtrans)'),
                    FormFieldDef(
                        key: 'api_format',
                        label: 'Format',
                        options: <String>[
                          'redirect_checkout',
                          'virtual_account',
                          'ewallet_deeplink',
                          'qris_dynamic'
                        ]),
                    FormFieldDef(key: 'api_key', label: 'API Key'),
                    FormFieldDef(key: 'secret_key', label: 'Secret Key'),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.storeProvider(
                    name: v['name']!,
                    apiFormat: v['api_format']!,
                    apiKey: v['api_key'],
                    secretKey: v['secret_key'],
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) {
                final int id = (e['id'] as num).toInt();
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.account_balance_outlined),
                    title: Text(e['name']?.toString() ?? '-'),
                    subtitle: Text(
                        '${e['api_format'] ?? '-'} • Aktif ${e['is_active'] ?? '-'}'),
                    trailing: IconButton(
                      tooltip: 'Tes koneksi',
                      icon: const Icon(Icons.wifi_find_outlined),
                      onPressed: () async {
                        Map<String, dynamic>? res;
                        await runMutation(context, () async {
                          res = await repo.testProvider(id);
                        });
                        if (context.mounted && res != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(res.toString())),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
            ModuleListPage(
              title: 'Channel',
              loader: repo.methods,
              emptyText: 'Belum ada channel aktif.',
              onCreate: () async {
                final Map<String, String>? v = await showFormDialog(
                  context,
                  title: 'Channel Baru',
                  fields: const <FormFieldDef>[
                    FormFieldDef(
                        key: 'payment_provider_id',
                        label: 'ID Provider',
                        isNumber: true),
                    FormFieldDef(key: 'code', label: 'Kode (mis. qris)'),
                    FormFieldDef(
                        key: 'display_name', label: 'Nama tampil (mis. QRIS)'),
                  ],
                );
                if (v == null || !context.mounted) return;
                await runMutation(
                  context,
                  () => repo.storeMethod(
                    providerId: int.parse(v['payment_provider_id']!),
                    code: v['code']!,
                    displayName: v['display_name']!,
                  ),
                );
              },
              itemBuilder: (BuildContext c, Map<String, dynamic> e) => Card(
                child: ListTile(
                  leading: const Icon(Icons.qr_code_outlined),
                  title: Text(e['display_name']?.toString() ?? '-'),
                  subtitle: Text('${e['code'] ?? '-'}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
