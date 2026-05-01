/// @description 셋업 화면 Widget 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see SetupScreen, SetupNotifier
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/auth/setup_notifier.dart';
import 'package:app/features/auth/setup_provider.dart';
import 'package:app/features/auth/setup_screen.dart';

class _FakeNotifier extends SetupNotifier {
  _FakeNotifier() : super(dio: Dio(), baseUrl: 'http://test');

  @override
  Future<void> submit({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    if (password.length < 8) {
      state = const SetupFailure('비밀번호는 8자 이상이어야 합니다.');
      return;
    }
    if (password != confirmPassword) {
      state = const SetupFailure('비밀번호가 일치하지 않습니다.');
      return;
    }
  }

  void emit(SetupState s) => state = s;
}

Widget _wrap(_FakeNotifier notifier) => ProviderScope(
      overrides: [
        setupProvider.overrideWith((_) => notifier),
      ],
      child: MaterialApp(
        routes: {
          '/': (_) => const SetupScreen(),
          '/library': (_) => const Scaffold(body: Text('LibraryScreen')),
        },
        initialRoute: '/',
      ),
    );

void main() {
  group('SetupScreen', () {
    late _FakeNotifier notifier;

    setUp(() => notifier = _FakeNotifier());

    testWidgets('password 불일치이면 에러 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));

      await tester.enterText(
        find.byKey(const Key('setup_username')),
        'admin',
      );
      await tester.enterText(
        find.byKey(const Key('setup_password')),
        'password123',
      );
      await tester.enterText(
        find.byKey(const Key('setup_confirm_password')),
        'different123',
      );
      await tester.tap(find.text('계정 생성'));
      await tester.pump();

      expect(find.text('비밀번호가 일치하지 않습니다.'), findsOneWidget);
    });

    testWidgets('password 8자 미만이면 에러 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));

      await tester.enterText(
        find.byKey(const Key('setup_username')),
        'admin',
      );
      await tester.enterText(
        find.byKey(const Key('setup_password')),
        'short',
      );
      await tester.enterText(
        find.byKey(const Key('setup_confirm_password')),
        'short',
      );
      await tester.tap(find.text('계정 생성'));
      await tester.pump();

      expect(find.text('비밀번호는 8자 이상이어야 합니다.'), findsOneWidget);
    });

    testWidgets('로딩 상태이면 CircularProgressIndicator가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const SetupLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('성공이면 라이브러리 화면으로 이동한다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const SetupSuccess());
      await tester.pumpAndSettle();

      expect(find.text('LibraryScreen'), findsOneWidget);
    });

    testWidgets('API 실패이면 에러 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const SetupFailure('계정 생성에 실패했습니다.'));
      await tester.pump();

      expect(find.text('계정 생성에 실패했습니다.'), findsOneWidget);
    });
  });
}
