/// @description 로그인 화면 Widget 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see LoginScreen, LoginNotifier
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/auth/login_notifier.dart';
import 'package:app/features/auth/login_provider.dart';
import 'package:app/features/auth/login_screen.dart';

class _FakeNotifier extends LoginNotifier {
  _FakeNotifier() : super(dio: Dio(), baseUrl: 'http://test');

  bool checkAutoLoginCalled = false;

  @override
  Future<void> checkAutoLogin() async {
    checkAutoLoginCalled = true;
  }

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {}

  void emit(LoginState s) => state = s;
}

Widget _wrap(_FakeNotifier notifier) => ProviderScope(
      overrides: [
        loginProvider.overrideWith((_) => notifier),
      ],
      child: MaterialApp(
        routes: {
          '/': (_) => const LoginScreen(),
          '/library': (_) => const Scaffold(body: Text('LibraryScreen')),
        },
        initialRoute: '/',
      ),
    );

void main() {
  group('LoginScreen', () {
    late _FakeNotifier notifier;

    setUp(() => notifier = _FakeNotifier());

    testWidgets('앱 진입 시 자동 로그인을 시도한다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      await tester.pump();

      expect(notifier.checkAutoLoginCalled, isTrue);
    });

    testWidgets('자동 로그인 실패이면 로그인 폼이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const LoginIdle());
      await tester.pump();

      expect(find.byKey(const Key('login_username')), findsOneWidget);
      expect(find.byKey(const Key('login_password')), findsOneWidget);
      expect(find.text('로그인'), findsOneWidget);
    });

    testWidgets('로딩 상태이면 CircularProgressIndicator가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const LoginLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('로그인 성공이면 라이브러리 화면으로 이동한다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const LoginSuccess());
      await tester.pumpAndSettle();

      expect(find.text('LibraryScreen'), findsOneWidget);
    });

    testWidgets('로그인 실패이면 에러 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const LoginFailure('로그인에 실패했습니다.'));
      await tester.pump();

      expect(find.text('로그인에 실패했습니다.'), findsOneWidget);
    });
  });
}
