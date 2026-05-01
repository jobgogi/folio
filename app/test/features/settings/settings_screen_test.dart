/// @description 설정 화면 Widget 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.05.01
/// @version 1.0.0
/// @see SettingsScreen, SettingsNotifier
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/theme_provider.dart';
import 'package:app/features/settings/settings_notifier.dart';
import 'package:app/features/settings/settings_provider.dart';
import 'package:app/features/settings/settings_screen.dart';

const _profile = SettingsProfile(username: 'admin');

class _FakeNotifier extends SettingsNotifier {
  _FakeNotifier() : super(dio: Dio(), baseUrl: 'http://test');

  bool fetchProfileCalled = false;
  bool syncCalled = false;
  bool logoutCalled = false;

  @override
  Future<void> fetchProfile() async {
    fetchProfileCalled = true;
  }

  @override
  Future<void> sync() async {
    syncCalled = true;
  }

  @override
  void logout() {
    logoutCalled = true;
    state = const SettingsLoggedOut();
  }

  void emit(SettingsState s) => state = s;
}

Widget _wrap(
  _FakeNotifier notifier, {
  List<NavigatorObserver> observers = const [],
}) {
  return ProviderScope(
    overrides: [
      settingsProvider.overrideWith((_) => notifier),
    ],
    child: Consumer(
      builder: (context, ref, _) {
        final themeMode = ref.watch(themeProvider);
        return MaterialApp(
          themeMode: themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          navigatorObservers: observers,
          routes: {
            '/login': (_) => const Scaffold(body: Text('LoginScreen')),
            '/server-address': (_) =>
                const Scaffold(body: Text('ServerAddressScreen')),
          },
          home: const SettingsScreen(),
        );
      },
    ),
  );
}

void main() {
  group('SettingsScreen', () {
    late _FakeNotifier notifier;

    setUp(() => notifier = _FakeNotifier());

    testWidgets('진입 시 fetchProfile이 호출된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));

      expect(notifier.fetchProfileCalled, isTrue);
    });

    testWidgets('SettingsLoaded 상태이면 username이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const SettingsLoaded(_profile));
      await tester.pump();

      expect(find.text('admin'), findsOneWidget);
    });

    testWidgets('아바타 변경 버튼이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const SettingsLoaded(_profile));
      await tester.pump();

      expect(find.byKey(const Key('settings_avatar_change')), findsOneWidget);
    });

    testWidgets('다크모드 토글 스위치 탭 시 themeProvider가 dark로 전환된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const SettingsLoaded(_profile));
      await tester.pump();

      await tester.tap(find.byKey(const Key('settings_dark_mode_toggle')));
      await tester.pump();

      // ProviderScope 내에서 themeProvider 값 확인
      final element = tester.element(find.byType(SettingsScreen));
      final container = ProviderScope.containerOf(element);
      expect(container.read(themeProvider), ThemeMode.dark);
    });

    testWidgets('동기화 버튼 탭 시 sync()가 호출된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const SettingsLoaded(_profile));
      await tester.pump();

      await tester.tap(find.byKey(const Key('settings_sync_button')));
      await tester.pump();

      expect(notifier.syncCalled, isTrue);
    });

    testWidgets('SettingsSyncing 상태이면 로딩 인디케이터가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const SettingsSyncing(_profile));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('SettingsSynced 상태이면 마지막 싱크 시간이 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(SettingsSynced(
        profile: _profile,
        lastSyncAt: DateTime(2026, 5, 1, 14, 30),
        added: 3,
        updated: 1,
        deleted: 0,
      ));
      await tester.pump();

      expect(find.text('2026.05.01 14:30'), findsOneWidget);
    });

    testWidgets('SettingsSynced 상태이면 동기화 결과가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(SettingsSynced(
        profile: _profile,
        lastSyncAt: DateTime(2026, 5, 1, 14, 30),
        added: 3,
        updated: 1,
        deleted: 0,
      ));
      await tester.pump();

      expect(find.byKey(const Key('settings_sync_result')), findsOneWidget);
      expect(find.text('추가 3  수정 1  삭제 0'), findsOneWidget);
    });

    testWidgets('로그아웃 버튼 탭 시 로그인 화면으로 이동한다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const SettingsLoaded(_profile));
      await tester.pump();

      await tester.tap(find.byKey(const Key('settings_logout_button')));
      await tester.pumpAndSettle();

      expect(find.text('LoginScreen'), findsOneWidget);
    });

    testWidgets('서버 주소 변경 탭 시 서버 주소 화면으로 이동한다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const SettingsLoaded(_profile));
      await tester.pump();

      await tester.tap(find.byKey(const Key('settings_server_address')));
      await tester.pumpAndSettle();

      expect(find.text('ServerAddressScreen'), findsOneWidget);
    });
  });
}
