/// @description LibraryNotifier 단위 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see LibraryNotifier
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/library/book_model.dart';
import 'package:app/features/library/library_notifier.dart';

class _MockAdapter implements HttpClientAdapter {
  _MockAdapter({
    this.booksPerPage = 2,
    this.hasMore = false,
    this.throwOnFetch = false,
  });

  final int booksPerPage;
  final bool hasMore;
  final bool throwOnFetch;
  bool syncCalled = false;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    if (options.path.contains('/v1/sync')) {
      syncCalled = true;
      return ResponseBody.fromString(
        '{"message":"ok"}',
        200,
        headers: {Headers.contentTypeHeader: ['application/json']},
      );
    }

    if (throwOnFetch) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: options, statusCode: 500),
      );
    }

    final books = List.generate(
      booksPerPage,
      (i) => {
        'id': '$i',
        'title': 'Book $i',
        'author': 'Author $i',
        'thumbnail': null,
      },
    );
    return ResponseBody.fromString(
      jsonEncode({'books': books, 'hasMore': hasMore}),
      200,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('BookModel', () {
    test('thumbnail이 null이면 null을 반환한다', () {
      const book = BookModel(id: '1', title: 'title', author: 'author');
      expect(book.thumbnail, isNull);
    });
  });

  group('LibraryNotifier', () {
    late Dio dio;
    late LibraryNotifier notifier;

    setUp(() {
      dio = Dio();
      notifier = LibraryNotifier(dio: dio, baseUrl: 'http://nas.local:3000');
    });

    test('초기 상태는 idle이다', () {
      expect(notifier.state, isA<LibraryIdle>());
    });

    group('fetch', () {
      test('책 목록 조회 성공이면 LibraryLoaded 상태가 된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(booksPerPage: 2);
        // Act
        await notifier.fetch(BookSort.name);
        // Assert
        expect(notifier.state, isA<LibraryLoaded>());
        expect((notifier.state as LibraryLoaded).books.length, 2);
      });

      test('책 목록 조회 실패이면 LibraryFailure 상태가 된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(throwOnFetch: true);
        // Act
        await notifier.fetch(BookSort.name);
        // Assert
        expect(notifier.state, isA<LibraryFailure>());
        expect(
          (notifier.state as LibraryFailure).message,
          '책 목록을 불러오는데 실패했습니다.',
        );
      });

      test('정렬 옵션이 변경되면 목록이 초기화되고 재조회된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(booksPerPage: 2);
        await notifier.fetch(BookSort.name);
        // Act — 다른 정렬로 재조회
        await notifier.fetch(BookSort.recentlyRead);
        // Assert — 누적이 아닌 초기화 후 2개
        expect((notifier.state as LibraryLoaded).books.length, 2);
      });
    });

    group('loadMore', () {
      test('loadMore 호출 시 다음 페이지 책이 기존 목록에 추가된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(booksPerPage: 2, hasMore: true);
        await notifier.fetch(BookSort.name);
        // Act
        await notifier.loadMore();
        // Assert
        expect((notifier.state as LibraryLoaded).books.length, 4);
      });

      test('loadMore 실패 시 기존 목록이 유지된다', () async {
        // Arrange
        dio.httpClientAdapter = _MockAdapter(booksPerPage: 2, hasMore: true);
        await notifier.fetch(BookSort.name);
        dio.httpClientAdapter = _MockAdapter(throwOnFetch: true);
        // Act
        await notifier.loadMore();
        // Assert
        expect(notifier.state, isA<LibraryLoaded>());
        expect((notifier.state as LibraryLoaded).books.length, 2);
      });
    });

    group('sync', () {
      test('sync 호출 시 POST /v1/sync가 실행된다', () async {
        // Arrange
        final adapter = _MockAdapter();
        dio.httpClientAdapter = adapter;
        await notifier.fetch(BookSort.name);
        // Act
        await notifier.sync();
        // Assert
        expect(adapter.syncCalled, isTrue);
      });
    });
  });
}
