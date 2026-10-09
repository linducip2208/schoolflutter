import 'package:dio/dio.dart';
import 'package:eschool_app/core/api/interceptors/auth_interceptor.dart';
import 'package:eschool_app/core/widgets/form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<RequestOptions> _run(
    String method, Map<String, dynamic>? headers) async {
  final RequestOptions options = RequestOptions(
    path: '/x',
    method: method,
    headers: headers,
  );
  final RequestInterceptorHandler handler = RequestInterceptorHandler();
  // ignore: invalid_use_of_visible_for_testing_member
  await AuthInterceptor().onRequest(options, handler);
  return options;
}

void main() {
  group('request hardening', () {
    test('POST gets a fresh Idempotency-Key', () async {
      final RequestOptions a = await _run('POST', null);
      final RequestOptions b = await _run('POST', null);
      expect(a.headers['Idempotency-Key'], isNotNull);
      expect(a.headers['Idempotency-Key'],
          isNot(equals(b.headers['Idempotency-Key'])));
    });

    test('GET never gets a key; existing keys preserved', () async {
      final RequestOptions g = await _run('GET', null);
      expect(g.headers.containsKey('Idempotency-Key'), isFalse);
      final RequestOptions p =
          await _run('POST', <String, dynamic>{'Idempotency-Key': 'fixed'});
      expect(p.headers['Idempotency-Key'], 'fixed');
    });

    testWidgets('double form open returns null once', (WidgetTester t) async {
      late BuildContext captured;
      await t.pumpWidget(MaterialApp(
        home: Builder(builder: (BuildContext c) {
          captured = c;
          return const SizedBox();
        }),
      ));
      final Future<Map<String, String>?> first = showFormDialog(
        captured,
        title: 'T',
        fields: const <FormFieldDef>[
          FormFieldDef(key: 'a', label: 'A'),
        ],
      );
      await t.pump();
      expect(find.byType(AlertDialog), findsOneWidget);
      // Second open while first is up resolves null immediately.
      final Map<String, String>? second = await showFormDialog(
        captured,
        title: 'T2',
        fields: const <FormFieldDef>[
          FormFieldDef(key: 'a', label: 'A'),
        ],
      );
      expect(second, isNull);
      expect(find.byType(AlertDialog), findsOneWidget);
      // Cancel the first; guard resets.
      await t.tap(find.text('Batal'));
      await t.pumpAndSettle();
      expect(await first, isNull);
    });
  });
}
