import 'package:eschool_app/features/auth/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SplashPage renders branded logo + spinner',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashPage()));

    expect(find.text('Sikad Pro'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget w) =>
            w is Image &&
            (w.image as AssetImage).assetName ==
                'assets/icons/sikad_pro_icon_master_1024.png',
      ),
      findsOneWidget,
    );
  });
}
