/// @description ServerAddressNotifier 단위 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.27
/// @version 1.0.0
/// @see ServerAddressNotifier
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/settings/server_address_notifier.dart';
import 'package:app/features/settings/server_address_repository.dart';

class _FakeRepository implements ServerAddressRepository {
  String? saved;

  @override
  Future<void> save(String address) async => saved = address;

  @override
  Future<String?> load() async => saved;
}

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter({
    this.healthStatusCode = 200,
    this.needsSetup,
    this.throwOnHealth = false,
  });

  final int healthStatusCode;
  final bool? needsSetup;
  final bool throwOnHealth;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    final path = options.uri.toString();
    if (throwOnHealth) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
      );
    }
    if (path.contains('/v1/health')) {
      if (healthStatusCode != 200) {
        return ResponseBody.fromString('Error', healthStatusCode);
      }
      return ResponseBody.fromString('OK', 200);
    }
    if (path.contains('/v1/auth/setup-status')) {
      return ResponseBody.fromString(
        '{"needsSetup":${needsSetup ?? false}}',
        200,
        headers: {Headers.contentTypeHeader: ['application/json']},
      );
    }
    throw StateError('Unexpected request: $path');
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ServerAddressNotifier', () {
    late _FakeRepository fakeRepository;
    late Dio dio;
    late ServerAddressNotifier notifier;

    setUp(() {
      fakeRepository = _FakeRepository();
      dio = Dio();
      notifier = ServerAddressNotifier(
        repository: fakeRepository,
        dio: dio,
      );
    });

    test('초기 상태는 idle이다', () {
      expect(notifier.state, isA<ServerAddressIdle>());
    });

    group('testAndSave', () {
      test('health 성공 + needsSetup true이면 setup 화면으로 이동한다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(needsSetup: true);
        // Act
        await notifier.testAndSave('http://nas.local:3000');
        // Assert
        expect(notifier.state, isA<ServerAddressSuccess>());
        expect(
          (notifier.state as ServerAddressSuccess).nextScreen,
          NextScreen.setup,
        );
      });

      test('health 성공 + needsSetup false이면 login 화면으로 이동한다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(needsSetup: false);
        // Act
        await notifier.testAndSave('http://nas.local:3000');
        // Assert
        expect(notifier.state, isA<ServerAddressSuccess>());
        expect(
          (notifier.state as ServerAddressSuccess).nextScreen,
          NextScreen.login,
        );
      });

      test('health 성공 시 서버 주소가 저장된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(needsSetup: false);
        // Act
        await notifier.testAndSave('http://nas.local:3000');
        // Assert
        expect(fakeRepository.saved, 'http://nas.local:3000');
      });

      test('연결 실패 시 failure 상태가 된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(throwOnHealth: true);
        // Act
        await notifier.testAndSave('http://nas.local:3000');
        // Assert
        expect(notifier.state, isA<ServerAddressFailure>());
        expect(
          (notifier.state as ServerAddressFailure).message,
          '서버에 연결할 수 없습니다.',
        );
      });

      test('연결 실패 시 주소가 저장되지 않는다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(throwOnHealth: true);
        // Act
        await notifier.testAndSave('http://nas.local:3000');
        // Assert
        expect(fakeRepository.saved, isNull);
      });
    });
  });
}
