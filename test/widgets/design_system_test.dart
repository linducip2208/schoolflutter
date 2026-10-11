import 'package:eschool_app/app/theme/app_colors.dart';
import 'package:eschool_app/core/widgets/app_confirm_dialog.dart';
import 'package:eschool_app/core/widgets/stat_card.dart';
import 'package:eschool_app/shells/_shell_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('roleColor returns per-role accent and falls back to primary', () {
    expect(AppColors.roleColor('teacher'), AppColors.roleAccent['teacher']);
    expect(AppColors.roleColor('unknown_role'), AppColors.primary);
  });

  testWidgets('ShellScaffold highlights Menu hub on unmatched detail route',
      (WidgetTester tester) async {
    const List<ShellNavItem> items = <ShellNavItem>[
      ShellNavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Beranda',
        route: '/t/dashboard',
      ),
      ShellNavItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view,
        label: 'Menu',
        route: '/t/menu',
      ),
    ];
    await tester.pumpWidget(
      const MaterialApp(
        home: ShellScaffold(
          location: '/t/attendance',
          items: items,
          fallbackIndex: 1,
          child: SizedBox.shrink(),
        ),
      ),
    );
    final NavigationBar bar = tester.widget(find.byType(NavigationBar));
    expect(bar.selectedIndex, 1);
  });

  testWidgets('ShellScaffold clamps out-of-range fallback to first tab',
      (WidgetTester tester) async {
    const List<ShellNavItem> items = <ShellNavItem>[
      ShellNavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Beranda',
        route: '/t/dashboard',
      ),
      ShellNavItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view,
        label: 'Menu',
        route: '/t/menu',
      ),
    ];
    await tester.pumpWidget(
      const MaterialApp(
        home: ShellScaffold(
          location: '/t/elsewhere',
          items: items,
          fallbackIndex: 9,
          child: SizedBox.shrink(),
        ),
      ),
    );
    final NavigationBar bar = tester.widget(find.byType(NavigationBar));
    expect(bar.selectedIndex, 0);
  });

  testWidgets('StatCard without onTap has no InkWell or button semantics',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(label: 'Siswa', value: '120', icon: Icons.school),
          ),
        ),
      );
      expect(find.byType(InkWell), findsNothing);
      // No explicit-label Semantics wrapper anywhere in the card subtree.
      expect(
        find.descendant(
          of: find.byType(StatCard),
          matching: find.byWidgetPredicate(
            (Widget w) =>
                w is Semantics && w.properties.label?.isNotEmpty == true,
          ),
        ),
        findsNothing,
      );
    } finally {
      handle.dispose();
    }
  });

  testWidgets('StatCard with onTap exposes button semantics',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatCard(
              label: 'Siswa',
              value: '120',
              icon: Icons.school,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      // Merged node label starts with the explicit card label.
      expect(find.bySemanticsLabel(RegExp('^Siswa: 120')), findsOneWidget);
      final SemanticsNode node = tester.getSemantics(
        find.byWidgetPredicate(
          (Widget w) =>
              w is Semantics && w.properties.label == 'Siswa: 120',
        ),
      );
      expect(node.flagsCollection.isButton, isTrue);
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(tapped, isTrue);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('showConfirmDialog returns true on confirm, false on cancel',
      (WidgetTester tester) async {
    bool? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            return ElevatedButton(
              onPressed: () async {
                result = await showConfirmDialog(
                  context,
                  title: 'Hapus?',
                  message: 'Yakin?',
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Hapus?'), findsOneWidget);
    await tester.tap(find.text('Hapus'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(result, isTrue);
  });
}
