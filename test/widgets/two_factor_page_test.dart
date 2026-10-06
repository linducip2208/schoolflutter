import 'package:bloc_test/bloc_test.dart';
import 'package:eschool_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:eschool_app/features/auth/presentation/pages/two_factor_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class _FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAuthEvent());
  });

  late _MockAuthBloc bloc;

  setUp(() => bloc = _MockAuthBloc());

  Future<void> pumpPage(WidgetTester tester) async {
    when(() => bloc.state).thenReturn(const AuthState(
      status: AuthStatus.twoFactorRequired,
      challengeId: 'challenge-1',
    ));
    when(() => bloc.stream).thenAnswer(
      (_) => const Stream<AuthState>.empty(),
    );
    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: bloc,
        child: const MaterialApp(home: TwoFactorPage()),
      ),
    );
  }

  testWidgets('shows code field and Verifikasi button', (WidgetTester t) async {
    await pumpPage(t);
    expect(find.text('Verifikasi Dua Langkah'), findsOneWidget);
    expect(find.text('Verifikasi'), findsOneWidget);
  });

  testWidgets('empty submit shows validation error', (WidgetTester t) async {
    await pumpPage(t);
    await t.tap(find.text('Verifikasi'));
    await t.pump();
    expect(find.text('Kode wajib diisi'), findsOneWidget);
  });

  testWidgets('valid code dispatches AuthTwoFactorVerifyRequested',
      (WidgetTester t) async {
    await pumpPage(t);
    await t.enterText(find.byType(TextFormField), '123456');
    await t.tap(find.text('Verifikasi'));
    await t.pump();
    verify(() => bloc.add(any(that: isA<AuthTwoFactorVerifyRequested>())))
        .called(1);
  });
}
