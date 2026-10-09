import 'package:flutter/material.dart';

import '../config/app_contact.dart';
import '../storage/app_storage.dart';

/// Testable persistence for the first-launch flag.
/// Production uses [PrefsFirstLaunchStore] (SharedPreferences via AppStorage).
/// Tests use [InMemoryFirstLaunchStore].
abstract class FirstLaunchStore {
  bool get seen;
  Future<void> markSeen();
}

class PrefsFirstLaunchStore implements FirstLaunchStore {
  @override
  bool get seen => AppStorage.getFirstLaunchSeen();
  @override
  Future<void> markSeen() => AppStorage.setFirstLaunchSeen();
}

class InMemoryFirstLaunchStore implements FirstLaunchStore {
  bool _seen = false;
  @override
  bool get seen => _seen;
  @override
  Future<void> markSeen() async => _seen = true;
}

/// Shows [WelcomePopup] once per install. Call from splash post-frame.
/// Dismiss (X / tap-outside / back) also persists seen=true per spec.
class FirstLaunchService {
  FirstLaunchService({required this.store});
  final FirstLaunchStore store;

  Future<void> maybeShow(BuildContext context) async {
    if (store.seen) return;
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const WelcomePopup(),
    );
    await store.markSeen();
  }
}

const List<String> _benefits = <String>[
  'Akademik',
  'Absensi',
  'Jadwal',
  'LMS',
  'Nilai',
  'Informasi',
];

class WelcomePopup extends StatelessWidget {
  const WelcomePopup({
    super.key,
    this.onStart,
    this.onContact,
    this.l10n,
  });

  /// Overrides for tests (bypass url_launcher / navigator).
  final VoidCallback? onStart;
  final Future<void> Function()? onContact;

  /// Localized strings override for hermetic tests. Defaults to Indonesian.
  final WelcomeStrings? l10n;

  @override
  Widget build(BuildContext context) {
    final WelcomeStrings s = l10n ?? WelcomeStrings.indonesian();
    final ThemeData theme = Theme.of(context);
    return Semantics(
      label: s.semanticsLabel,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Align(
                    alignment: Alignment.topRight,
                    child: Semantics(
                      label: s.closeLabel,
                      button: true,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        tooltip: s.closeLabel,
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        size: 40,
                        color: theme.colorScheme.onPrimaryContainer,
                        semanticLabel: s.logoLabel,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    s.subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final String b in _benefits)
                        Chip(
                          label: Text(b),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: () {
                      if (onStart != null) {
                        onStart!();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(s.startLabel),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      if (onContact != null) {
                        await onContact!();
                        return;
                      }
                      try {
                        await SupportContact.openWhatsApp();
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                    icon: const Icon(Icons.chat_outlined, size: 18),
                    label: Text(
                      '${s.contactLabel}\n${SupportContact.whatsappDisplay}',
                      textAlign: TextAlign.center,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeStrings {
  WelcomeStrings({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.startLabel,
    required this.contactLabel,
    required this.closeLabel,
    required this.semanticsLabel,
    required this.logoLabel,
  });

  final String title;
  final String subtitle;
  final String description;
  final String startLabel;
  final String contactLabel;
  final String closeLabel;
  final String semanticsLabel;
  final String logoLabel;

  factory WelcomeStrings.indonesian() => WelcomeStrings(
        title: 'Selamat Datang di Sikad Pro',
        subtitle: 'Platform digital sekolah terpadu',
        description:
            'Mendukung kegiatan akademik, komunikasi, dan operasional sekolah untuk siswa, orang tua, guru, dan manajemen.',
        startLabel: 'Mulai Menggunakan',
        contactLabel: 'Hubungi Kami via WhatsApp',
        closeLabel: 'Tutup',
        semanticsLabel: 'Sambutan selamat datang Sikad Pro',
        logoLabel: 'Logo Sikad Pro',
      );

  factory WelcomeStrings.english() => WelcomeStrings(
        title: 'Welcome to Sikad Pro',
        subtitle: 'Integrated school digital platform',
        description:
            'Supporting academics, communication, and school operations for students, parents, teachers, and management.',
        startLabel: 'Get Started',
        contactLabel: 'Contact Us via WhatsApp',
        closeLabel: 'Close',
        semanticsLabel: 'Sikad Pro welcome greeting',
        logoLabel: 'Sikad Pro logo',
      );
}
