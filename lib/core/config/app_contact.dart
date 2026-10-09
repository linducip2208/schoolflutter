import 'package:url_launcher/url_launcher.dart';

/// Single source of truth for Sikad Pro support contact.
///
/// WhatsApp number 081296052010 is normalized once here and never
/// hardcoded in widgets. All UI (welcome popup, About page, settings)
/// must use [SupportContact].
class SupportContact {
  SupportContact._();

  /// Display format shown to users.
  static const String whatsappDisplay = '0812 9605 2010';

  /// Raw local format (for reference only).
  static const String whatsappRaw = '081296052010';

  /// Normalized international format without '+'.
  static const String whatsappNormalized = '6281296052010';

  /// Prefilled professional message (Indonesian).
  static const String whatsappMessage =
      'Halo Sikad Pro, saya ingin mendapatkan informasi mengenai aplikasi dan layanan Sikad Pro.';

  /// Full wa.me URL with encoded prefilled message.
  static Uri get whatsappUrl => Uri.parse(
        'https://wa.me/$whatsappNormalized?text=${Uri.encodeComponent(whatsappMessage)}',
      );

  /// English variant for en-locale CTA fallback/tests.
  static Uri whatsappUrlFor(String message) => Uri.parse(
        'https://wa.me/$whatsappNormalized?text=${Uri.encodeComponent(message)}',
      );

  /// Opens WhatsApp (app if installed, else browser).
  /// Throws a user-friendly [SupportLaunchException] on failure — never crashes.
  /// [launcher] is injectable for tests.
  static Future<void> openWhatsApp({
    Future<bool> Function(Uri url)? launcher,
  }) async {
    final Future<bool> Function(Uri url) launch = launcher ??
        (Uri url) => launchUrl(url, mode: LaunchMode.externalApplication);
    try {
      final bool ok = await launch(whatsappUrl);
      if (!ok) throw SupportLaunchException();
    } catch (_) {
      throw SupportLaunchException();
    }
  }
}

class SupportLaunchException implements Exception {
  String get message =>
      'Tidak dapat membuka WhatsApp. Silakan hubungi 0812 9605 2010.';
  @override
  String toString() => message;
}
