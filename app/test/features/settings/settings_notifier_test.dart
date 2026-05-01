/// @description SettingsNotifier 단위 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.05.01
/// @version 1.0.0
/// @see SettingsNotifier
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/settings/settings_notifier.dart';

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter({
    this.meData =
        '{"id":"1","username":"admin","role":"admin","avatar":null}',
    this.syncData = '{"added":3,"updated":1,"deleted":0}',
    this.throwOnMe = false,
    this.throwOnSync = false,
  });

  final String meData;
  final String syncData;
  final bool throwOnMe;
  final bool throwOnSync;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    final isSync = options.path.contains('/sync');

    if (isSync) {
      if (throwOnSync) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: options, statusCode: 500),
        );
      }
      return ResponseBody.fromString(
        syncData,
        200,
        headers: {
          Headers.contentTypeHeader: ['application/json'],
        },
      );
    }

    if (throwOnMe) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: options, statusCode: 401),
      );
    }
    return ResponseBody.fromString(
      meData,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('SettingsNotifier', () {
    late Dio dio;
    late SettingsNotifier notifier;

    setUp(() {
      dio = Dio();
      notifier = SettingsNotifier(dio: dio, baseUrl: 'http://nas.local:3000');
    });

    test('초기 상태는 idle이다', () {
      expect(notifier.state, isA<SettingsIdle>());
    });

    group('fetchProfile', () {
      test('성공이면 SettingsLoaded 상태가 되고 username이 채워진다', () async {
        dio.httpClientAdapter = _MockAdapter();

        await notifier.fetchProfile();

        expect(notifier.state, isA<SettingsLoaded>());
        expect((notifier.state as SettingsLoaded).profile.username, 'admin');
        expect((notifier.state as SettingsLoaded).profile.avatar, isNull);
      });

      test('실패이면 SettingsFailure 상태가 된다', () async {
        dio.httpClientAdapter = _MockAdapter(throwOnMe: true);

        await notifier.fetchProfile();

        expect(notifier.state, isA<SettingsFailure>());
        expect(
          (notifier.state as SettingsFailure).message,
          '프로필을 불러오는데 실패했습니다.',
        );
      });

      test('trailing slash가 포함된 baseUrl도 정상 처리된다', () async {
        final n = SettingsNotifier(
          dio: dio,
          baseUrl: 'http://nas.local:3000/',
        );
        dio.httpClientAdapter = _MockAdapter();

        await n.fetchProfile();

        expect(n.state, isA<SettingsLoaded>());
      });
    });

    group('sync', () {
      test('SettingsLoaded 상태에서 동기화 성공이면 SettingsSynced 상태가 된다', () async {
        dio.httpClientAdapter = _MockAdapter();
        await notifier.fetchProfile();

        await notifier.sync();

        expect(notifier.state, isA<SettingsSynced>());
        final synced = notifier.state as SettingsSynced;
        expect(synced.added, 3);
        expect(synced.updated, 1);
        expect(synced.deleted, 0);
        expect(synced.profile.username, 'admin');
      });

      test('SettingsSynced 상태에서 재동기화 성공이면 SettingsSynced 상태가 된다', () async {
        dio.httpClientAdapter = _MockAdapter();
        await notifier.fetchProfile();
        await notifier.sync();

        dio.httpClientAdapter = _MockAdapter(
          syncData: '{"added":0,"updated":2,"deleted":1}',
        );
        await notifier.sync();

        expect(notifier.state, isA<SettingsSynced>());
        final synced = notifier.state as SettingsSynced;
        expect(synced.updated, 2);
        expect(synced.deleted, 1);
      });

      test('동기화 실패이면 SettingsSyncFailed 상태가 된다', () async {
        dio.httpClientAdapter = _MockAdapter();
        await notifier.fetchProfile();

        dio.httpClientAdapter = _MockAdapter(throwOnSync: true);
        await notifier.sync();

        expect(notifier.state, isA<SettingsSyncFailed>());
        expect(
          (notifier.state as SettingsSyncFailed).message,
          '동기화에 실패했습니다.',
        );
      });

      test('프로필 미로드 상태에서 sync 호출 시 상태가 변하지 않는다', () async {
        await notifier.sync();

        expect(notifier.state, isA<SettingsIdle>());
      });
    });

    group('logout', () {
      test('logout 호출 시 SettingsLoggedOut 상태가 된다', () {
        notifier.logout();

        expect(notifier.state, isA<SettingsLoggedOut>());
      });
    });
  });
}
