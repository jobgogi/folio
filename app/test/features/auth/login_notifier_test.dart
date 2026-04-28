/// @description LoginNotifier 단위 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see LoginNotifier
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/auth/login_notifier.dart';

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter({
    this.loginStatusCode = 200,
    this.meStatusCode = 200,
    this.throwOnLogin = false,
    this.throwOnMe = false,
  });

  final int loginStatusCode;
  final int meStatusCode;
  final bool throwOnLogin;
  final bool throwOnMe;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    final isMe = options.path.contains('/me');

    if (isMe) {
      if (throwOnMe) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: options, statusCode: 401),
        );
      }
      return ResponseBody.fromString(
        '{"id":"1","username":"admin","role":"admin","avatar":null}',
        meStatusCode,
        headers: {Headers.contentTypeHeader: ['application/json']},
      );
    }

    if (throwOnLogin) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: options, statusCode: 401),
      );
    }
    return ResponseBody.fromString(
      '{"message":"ok"}',
      loginStatusCode,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('LoginNotifier', () {
    late Dio dio;
    late LoginNotifier notifier;

    setUp(() {
      dio = Dio();
      notifier = LoginNotifier(dio: dio, baseUrl: 'http://nas.local:3000');
    });

    test('초기 상태는 idle이다', () {
      expect(notifier.state, isA<LoginIdle>());
    });

    group('login', () {
      test('로그인 성공이면 success 상태가 된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(loginStatusCode: 200);
        // Act
        await notifier.login(username: 'admin', password: 'password123');
        // Assert
        expect(notifier.state, isA<LoginSuccess>());
      });

      test('로그인 실패이면 failure 상태가 된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(throwOnLogin: true);
        // Act
        await notifier.login(username: 'admin', password: 'wrongpassword');
        // Assert
        expect(notifier.state, isA<LoginFailure>());
        expect(
          (notifier.state as LoginFailure).message,
          '로그인에 실패했습니다.',
        );
      });

      test('trailing slash가 포함된 baseUrl도 정상 처리된다', () async {
        // Arrange
        final notifierWithSlash = LoginNotifier(
          dio: dio,
          baseUrl: 'http://nas.local:3000/',
        );
        dio.httpClientAdapter = _MockAdapter(loginStatusCode: 200);
        // Act
        await notifierWithSlash.login(
          username: 'admin',
          password: 'password123',
        );
        // Assert
        expect(notifierWithSlash.state, isA<LoginSuccess>());
      });
    });

    group('checkAutoLogin', () {
      test('GET /v1/auth/me 성공이면 success 상태가 된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(meStatusCode: 200);
        // Act
        await notifier.checkAutoLogin();
        // Assert
        expect(notifier.state, isA<LoginSuccess>());
      });

      test('GET /v1/auth/me 실패이면 idle 상태가 된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(throwOnMe: true);
        // Act
        await notifier.checkAutoLogin();
        // Assert
        expect(notifier.state, isA<LoginIdle>());
      });
    });
  });
}
