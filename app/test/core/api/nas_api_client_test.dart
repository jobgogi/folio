import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:app/core/api/nas_api_client.dart';
import 'package:app/core/file_detector.dart';
import 'package:app/core/file_model.dart';

import 'nas_api_client_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('NasApiClient', () {
    late MockDio mockDio;
    late NasApiClient client;

    setUp(() {
      mockDio = MockDio();
      client = NasApiClient(dio: mockDio);
    });

    group('ping', () {
      test('서버 응답이 200이면 true를 반환한다', () async {
        // Arrange
        when(mockDio.get('/health')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/health'),
            statusCode: 200,
          ),
        );
        // Act
        final result = await client.ping();
        // Assert
        expect(result, isTrue);
      });

      test('서버 응답이 503이면 false를 반환한다', () async {
        when(mockDio.get('/health')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/health'),
            statusCode: 503,
          ),
        );
        final result = await client.ping();
        expect(result, isFalse);
      });

      test('네트워크 오류가 발생하면 false를 반환한다', () async {
        when(mockDio.get('/health')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/health'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        final result = await client.ping();
        expect(result, isFalse);
      });
    });

    group('getFiles', () {
      test('파일 목록을 반환한다', () async {
        // Arrange
        when(mockDio.get('/files', queryParameters: {'path': '/'})).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/files'),
            statusCode: 200,
            data: [
              {
                'id': 'file-001',
                'name': 'book.pdf',
                'type': 'pdf',
                'path': '/pdf/book.pdf',
                'lastOpenedAt': null,
              },
            ],
          ),
        );
        // Act
        final result = await client.getFiles('/');
        // Assert
        expect(result.length, 1);
        expect(result.first.id, 'file-001');
        expect(result.first.name, 'book.pdf');
        expect(result.first.type, FileType.pdf);
        expect(result.first.path, '/pdf/book.pdf');
      });

      test('빈 목록을 반환하면 빈 리스트를 반환한다', () async {
        when(mockDio.get('/files', queryParameters: {'path': '/empty'})).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/files'),
            statusCode: 200,
            data: [],
          ),
        );
        final result = await client.getFiles('/empty');
        expect(result, isEmpty);
      });

      test('네트워크 오류가 발생하면 NasClientException을 던진다', () async {
        when(mockDio.get('/files', queryParameters: {'path': '/'})).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/files'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        expect(() => client.getFiles('/'), throwsA(isA<NasClientException>()));
      });
    });

    group('getFile', () {
      test('id로 단일 파일 정보를 반환한다', () async {
        // Arrange
        when(mockDio.get('/files/file-001')).thenAnswer(
          (_) async => Response(
            requestOptions: RequestOptions(path: '/files/file-001'),
            statusCode: 200,
            data: {
              'id': 'file-001',
              'name': 'book.pdf',
              'type': 'pdf',
              'path': '/pdf/book.pdf',
              'lastOpenedAt': null,
            },
          ),
        );
        // Act
        final result = await client.getFile('file-001');
        // Assert
        expect(result, isNotNull);
        expect(result!.id, 'file-001');
        expect(result.name, 'book.pdf');
      });

      test('404 응답이면 null을 반환한다', () async {
        when(mockDio.get('/files/not-exist')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/files/not-exist'),
            response: Response(
              requestOptions: RequestOptions(path: '/files/not-exist'),
              statusCode: 404,
            ),
            type: DioExceptionType.badResponse,
          ),
        );
        final result = await client.getFile('not-exist');
        expect(result, isNull);
      });

      test('네트워크 오류가 발생하면 NasClientException을 던진다', () async {
        when(mockDio.get('/files/file-001')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/files/file-001'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        expect(() => client.getFile('file-001'), throwsA(isA<NasClientException>()));
      });
    });

    group('JWT 인터셉터', () {
      test('token을 주입하면 인터셉터가 등록된다', () {
        // Arrange
        final dio = Dio();
        // Act
        final clientWithToken = NasApiClient(dio: dio, token: 'test-token');
        // Assert
        expect(clientWithToken.hasAuthInterceptor, isTrue);
      });

      test('token 없이 생성하면 인터셉터가 등록되지 않는다', () {
        final dio = Dio();
        final clientWithoutToken = NasApiClient(dio: dio);
        expect(clientWithoutToken.hasAuthInterceptor, isFalse);
      });
    });
  });
}
