/// @description 서버 주소 입력 화면 Widget 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see ServerAddressScreen, ServerAddressNotifier
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/settings/server_address_notifier.dart';
import 'package:app/features/settings/server_address_provider.dart';
import 'package:app/features/settings/server_address_repository.dart';
import 'package:app/features/settings/server_address_screen.dart';

class _FakeRepo implements ServerAddressRepository {
  @override
  Future<void> save(String address) async {}
  @override
  Future<String?> load() async => null;
}

class _FakeNotifier extends ServerAddressNotifier {
  _FakeNotifier() : super(repository: _FakeRepo(), dio: Dio());

  @override
  Future<void> testAndSave(String address) async {}

  void emit(ServerAddressState s) => state = s;
}

Widget _wrap(_FakeNotifier notifier) => ProviderScope(
      overrides: [
        serverAddressProvider.overrideWith((_) => notifier),
      ],
      child: MaterialApp(
        routes: {
          '/': (_) => const ServerAddressScreen(),
          '/setup': (_) => const Scaffold(body: Text('SetupScreen')),
          '/login': (_) => const Scaffold(body: Text('LoginScreen')),
        },
        initialRoute: '/',
      ),
    );

void main() {
  group('ServerAddressScreen', () {
    late _FakeNotifier notifier;

    setUp(() => notifier = _FakeNotifier());

    testWidgets('주소를 입력하지 않으면 연결 테스트 버튼이 비활성화된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));

      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '연결 테스트'),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('주소를 입력하면 연결 테스트 버튼이 활성화된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));

      await tester.enterText(find.byType(TextField), 'http://nas.local:3000');
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '연결 테스트'),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('로딩 상태이면 CircularProgressIndicator가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const ServerAddressLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('연결 성공이면 성공 메시지와 다음 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const ServerAddressSuccess(NextScreen.setup));
      await tester.pump();

      expect(find.text('연결되었습니다.'), findsOneWidget);
      expect(find.text('다음'), findsOneWidget);
    });

    testWidgets('연결 실패이면 에러 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const ServerAddressFailure('서버에 연결할 수 없습니다.'));
      await tester.pump();

      expect(find.text('서버에 연결할 수 없습니다.'), findsOneWidget);
    });

    testWidgets('needsSetup true이면 셋업 화면으로 이동한다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const ServerAddressSuccess(NextScreen.setup));
      await tester.pump();

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('SetupScreen'), findsOneWidget);
    });

    testWidgets('needsSetup false이면 로그인 화면으로 이동한다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const ServerAddressSuccess(NextScreen.login));
      await tester.pump();

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('LoginScreen'), findsOneWidget);
    });
  });
}
