/// @description SetupNotifier 단위 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see SetupNotifier
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/auth/setup_notifier.dart';

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter({this.statusCode = 201, this.throwError = false});

  final int statusCode;
  final bool throwError;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    if (throwError) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 403,
        ),
      );
    }
    return ResponseBody.fromString(
      '{"message":"ok"}',
      statusCode,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('SetupNotifier', () {
    late Dio dio;
    late SetupNotifier notifier;

    setUp(() {
      dio = Dio();
      notifier = SetupNotifier(dio: dio, baseUrl: 'http://nas.local:3000');
    });

    test('초기 상태는 idle이다', () {
      expect(notifier.state, isA<SetupIdle>());
    });

    group('submit', () {
      test('password가 8자 미만이면 failure 상태가 되고 API를 호출하지 않는다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter();
        // Act
        await notifier.submit(
          username: 'admin',
          password: 'short',
          confirmPassword: 'short',
        );
        // Assert
        expect(notifier.state, isA<SetupFailure>());
        expect(
          (notifier.state as SetupFailure).message,
          '비밀번호는 8자 이상이어야 합니다.',
        );
      });

      test('password와 confirmPassword가 다르면 failure 상태가 되고 API를 호출하지 않는다',
          () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter();
        // Act
        await notifier.submit(
          username: 'admin',
          password: 'password123',
          confirmPassword: 'different1',
        );
        // Assert
        expect(notifier.state, isA<SetupFailure>());
        expect(
          (notifier.state as SetupFailure).message,
          '비밀번호가 일치하지 않습니다.',
        );
      });

      test('유효성 검증 통과 후 API 성공이면 success 상태가 된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(statusCode: 201);
        // Act
        await notifier.submit(
          username: 'admin',
          password: 'password123',
          confirmPassword: 'password123',
        );
        // Assert
        expect(notifier.state, isA<SetupSuccess>());
      });

      test('trailing slash가 포함된 baseUrl도 정상 처리된다', () async {
        // Arrange
        final notifierWithSlash = SetupNotifier(
          dio: dio,
          baseUrl: 'http://nas.local:3000/',
        );
        dio.httpClientAdapter = _MockAdapter(statusCode: 201);
        // Act
        await notifierWithSlash.submit(
          username: 'admin',
          password: 'password123',
          confirmPassword: 'password123',
        );
        // Assert
        expect(notifierWithSlash.state, isA<SetupSuccess>());
      });

      test('API 호출 실패이면 failure 상태가 된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(throwError: true);
        // Act
        await notifier.submit(
          username: 'admin',
          password: 'password123',
          confirmPassword: 'password123',
        );
        // Assert
        expect(notifier.state, isA<SetupFailure>());
        expect(
          (notifier.state as SetupFailure).message,
          '계정 생성에 실패했습니다.',
        );
      });
    });
  });
}
