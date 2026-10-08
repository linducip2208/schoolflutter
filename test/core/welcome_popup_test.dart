import 'package:eschool_app/core/config/app_contact.dart';
import 'package:eschool_app/core/widgets/welcome_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: brightness,
      ),
      useMaterial3: true,
    ),
    home: Scaffold(body: child),
  );
}

Future<void> _pumpPopup(
  WidgetTester tester, {
  WelcomeStrings? l10n,
  VoidCallback? onStart,
  Future<void> Function()? onContact,
  double textScale = 1.0,
  Size? surface,
}) async {
  if (surface != null) tester.view.physicalSize = surface;
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: _wrap(
        WelcomePopup(onStart: onStart, onContact: onContact, l10n: l10n),
      ),
    ),
  );
  await tester.pumpAndSettle();
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

void main() {
  group('SupportContact (centralized WA)', () {
    test('TEST 5: correct normalized URL generated', () {
      final Uri u = SupportContact.whatsappUrl;
      expect(u.scheme, 'https');
      expect(u.host, 'wa.me');
      expect(u.path, '/6281296052010');
      expect(u.query, contains('text='));
      expect(SupportContact.whatsappNormalized, '6281296052010');
      expect(SupportContact.whatsappRaw, '081296052010');
    });

    test('openWhatsApp throws friendly error when launcher fails', () async {
      await expectLater(
        SupportContact.openWhatsApp(launcher: (_) async => false),
        throwsA(isA<SupportLaunchException>()),
      );
    });
  });

  group('WelcomePopup widget', () {
    testWidgets('TEST 1: fresh popup visible (ID)', (tester) async {
      await _pumpPopup(tester, l10n: WelcomeStrings.indonesian());
      expect(find.text('Selamat Datang di eSchool'), findsOneWidget);
      expect(find.text('Mulai Menggunakan'), findsOneWidget);
      expect(
        find.textContaining('Hubungi Kami via WhatsApp'),
        findsOneWidget,
      );
      for (final String b in <String>[
        'Akademik',
        'Absensi',
        'Jadwal',
        'LMS',
        'Nilai',
        'Informasi',
      ]) {
        expect(find.text(b), findsOneWidget);
      }
    });

    testWidgets('TEST 7/8: localized English', (tester) async {
      await _pumpPopup(tester, l10n: WelcomeStrings.english());
      expect(find.text('Welcome to eSchool'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('TEST 4: tap Mulai Menggunakan triggers onStart', (
      tester,
    ) async {
      bool tapped = false;
      await _pumpPopup(
        tester,
        onStart: () => tapped = true,
      );
      await tester.tap(find.text('Mulai Menggunakan'));
      expect(tapped, isTrue);
    });

    testWidgets('TEST 6: contact CTA uses injected handler (fallback path)', (
      tester,
    ) async {
      bool contacted = false;
      await _pumpPopup(
        tester,
        onContact: () async => contacted = true,
      );
      await tester.tap(find.textContaining('Hubungi Kami via WhatsApp'));
      await tester.pumpAndSettle();
      expect(contacted, isTrue);
    });

    testWidgets('TEST 9: large text scale does not overflow', (tester) async {
      await _pumpPopup(tester, textScale: 2.0);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Selamat Datang di eSchool'), findsOneWidget);
    });

    testWidgets('TEST 10: small screen renders', (tester) async {
      await _pumpPopup(tester, surface: const Size(320, 568));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Mulai Menggunakan'), findsOneWidget);
    });

    testWidgets('TEST 11: dark mode renders', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: _wrap(
            const WelcomePopup(),
            brightness: Brightness.dark,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Selamat Datang di eSchool'), findsOneWidget);
    });

    testWidgets('TEST 12: light mode renders', (tester) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(),
          child: _wrap(
            const WelcomePopup(),
            brightness: Brightness.light,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('accessibility: close button has 48px touch target', (
      tester,
    ) async {
      await _pumpPopup(tester);
      final Finder btn = find.widgetWithIcon(IconButton, Icons.close_rounded);
      expect(btn, findsOneWidget);
      final Size size = tester.getSize(btn);
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });
  });

  group('FirstLaunchService', () {
    testWidgets('TEST 2/3/13: shows once, persists, no repeat', (tester) async {
      final InMemoryFirstLaunchStore store = InMemoryFirstLaunchStore();
      final FirstLaunchService svc = FirstLaunchService(store: store);

      await tester.pumpWidget(
        _wrap(Builder(builder: (BuildContext c) => const SizedBox())),
      );
      final BuildContext ctx = tester.element(find.byType(SizedBox));

      // First launch → dialog appears.
      unawaitedForTest(svc.maybeShow(ctx));
      await tester.pumpAndSettle();
      expect(find.byType(WelcomePopup), findsOneWidget);

      // TEST 2: dismiss persists seen.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(store.seen, isTrue);

      // TEST 3/13: second call → no dialog.
      await svc.maybeShow(ctx);
      await tester.pump();
      expect(find.byType(WelcomePopup), findsNothing);
    });
  });
}

void unawaitedForTest(Future<void> f) {
  f.ignore();
}
