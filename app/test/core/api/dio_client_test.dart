/// @description DioClient 단위 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.27
/// @version 1.0.0
/// @see DioClient
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/api/dio_client.dart';

class _Mock401Adapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"message":"Unauthorized"}',
      401,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _MockTimeoutAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionTimeout,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('DioClient', () {
    late Dio dio;
    late CookieJar cookieJar;

    setUp(() {
      dio = Dio();
      cookieJar = CookieJar();
    });

    group('Dio 인스턴스 설정', () {
      test('baseUrl이 올바르게 설정된다', () {
        // Arrange & Act
        DioClient(
          dio: dio,
          baseUrl: 'http://nas.local:3000',
          cookieJar: cookieJar,
        );
        // Assert
        expect(dio.options.baseUrl, 'http://nas.local:3000');
      });

      test('withCredentials가 true로 설정된다', () {
        // Arrange & Act
        DioClient(
          dio: dio,
          baseUrl: 'http://nas.local:3000',
          cookieJar: cookieJar,
        );
        // Assert
        expect(dio.options.extra['withCredentials'], isTrue);
      });

      test('쿠키 인터셉터(CookieManager)가 등록된다', () {
        // Arrange & Act
        final client = DioClient(
          dio: dio,
          baseUrl: 'http://nas.local:3000',
          cookieJar: cookieJar,
        );
        // Assert
        expect(client.hasCookieInterceptor, isTrue);
      });
    });

    group('401 응답 → 로그인 리다이렉트', () {
      test('401 응답이 오면 onUnauthorized 콜백이 호출된다', () async {
        // Arrange
        bool redirectCalled = false;
        DioClient(
          dio: dio,
          baseUrl: 'http://nas.local:3000',
          cookieJar: cookieJar,
          onUnauthorized: () => redirectCalled = true,
        );
        dio.httpClientAdapter = _Mock401Adapter();
        // Act
        try {
          await dio.get('/v1/auth/me');
        } on DioException {
          // 401은 DioException(badResponse)으로 전파됨
        }
        // Assert
        expect(redirectCalled, isTrue);
      });

      test('401이 아닌 에러에서는 onUnauthorized 콜백이 호출되지 않는다', () async {
        // Arrange
        bool redirectCalled = false;
        DioClient(
          dio: dio,
          baseUrl: 'http://nas.local:3000',
          cookieJar: cookieJar,
          onUnauthorized: () => redirectCalled = true,
        );
        dio.httpClientAdapter = _MockTimeoutAdapter();
        // Act
        try {
          await dio.get('/v1/books');
        } on DioException {
          // timeout은 DioException(connectionTimeout)으로 전파됨
        }
        // Assert
        expect(redirectCalled, isFalse);
      });
    });

    group('네트워크 에러 처리', () {
      test('연결 타임아웃 시 DioException이 전파된다', () async {
        // Arrange
        DioClient(
          dio: dio,
          baseUrl: 'http://nas.local:3000',
          cookieJar: cookieJar,
        );
        dio.httpClientAdapter = _MockTimeoutAdapter();
        // Act & Assert
        await expectLater(
          () => dio.get('/v1/books'),
          throwsA(isA<DioException>()),
        );
      });

      test('전파된 DioException의 타입이 connectionTimeout이다', () async {
        // Arrange
        DioClient(
          dio: dio,
          baseUrl: 'http://nas.local:3000',
          cookieJar: cookieJar,
        );
        dio.httpClientAdapter = _MockTimeoutAdapter();
        // Act & Assert
        await expectLater(
          () => dio.get('/v1/books'),
          throwsA(
            isA<DioException>().having(
              (e) => e.type,
              'type',
              DioExceptionType.connectionTimeout,
            ),
          ),
        );
      });
    });
  });
}
