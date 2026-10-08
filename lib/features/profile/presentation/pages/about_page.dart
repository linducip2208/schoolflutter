import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_contact.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';

/// Settings → Tentang eSchool → Hubungi Kami.
/// Reuses [SupportContact] (same source of truth as welcome popup).
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  Future<void> _contact() async {
    try {
      await SupportContact.openWhatsApp();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka tautan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang eSchool')),
      body: FutureBuilder<PackageInfo>(
        future: _info,
        builder: (BuildContext c, AsyncSnapshot<PackageInfo> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const AppLoading();
          }
          if (snap.hasError) {
            return AppError(
              message: '${snap.error}',
              onRetry: () => setState(() {}),
            );
          }
          final PackageInfo info = snap.data ??
              PackageInfo(
                appName: 'eSchool',
                packageName: '',
                version: '-',
                buildNumber: '-',
              );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        size: 40,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      info.appName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Versi ${info.version} (${info.buildNumber})',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Platform digital sekolah terpadu untuk siswa, orang tua, guru, dan manajemen sekolah.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.chat_outlined),
                      title: const Text('Hubungi Kami'),
                      subtitle: const Text(
                        'WhatsApp ${SupportContact.whatsappDisplay}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _contact,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Kebijakan Privasi'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openUrl(
                        'https://sikadpro.whitelabel.co.id/privacy',
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: const Text('Syarat & Ketentuan'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openUrl(
                        'https://sikadpro.whitelabel.co.id/terms',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _contact,
                icon: const Icon(Icons.chat_outlined, size: 18),
                label: const Text('Hubungi Kami via WhatsApp'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
