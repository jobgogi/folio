/// @description CacheManager 단위 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see CacheManager
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/cache/cache_manager.dart';

class _MockDownloadAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      'fake-content',
      200,
      headers: {Headers.contentTypeHeader: ['application/octet-stream']},
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('CacheManager', () {
    late Dio dio;
    late Directory tempDir;
    late CacheManager cacheManager;

    setUp(() {
      dio = Dio();
      tempDir = Directory.systemTemp.createTempSync('folio_cache_test_');
      cacheManager = CacheManager(storageDir: tempDir.path, dio: dio);
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('파일이 존재하면 다운로드 없이 로컬 경로를 반환한다', () async {
      // Arrange — 미리 파일 생성
      final path = '${tempDir.path}/folio/books/book1.pdf';
      File(path).createSync(recursive: true);
      // Act
      final result = await cacheManager.resolve(
        bookId: 'book1',
        ext: 'pdf',
        type: CacheType.book,
        downloadUrl: 'http://nas.local:3000/v1/books/book1/file',
      );
      // Assert
      expect(result, path);
    });

    test('파일이 없으면 다운로드 후 저장된다', () async {
      // Arrange
      dio.httpClientAdapter = _MockDownloadAdapter();
      // Act
      final result = await cacheManager.resolve(
        bookId: 'book1',
        ext: 'pdf',
        type: CacheType.book,
        downloadUrl: 'http://nas.local:3000/v1/books/book1/file',
      );
      // Assert
      expect(File(result).existsSync(), isTrue);
    });

    test('저장 경로를 변경하면 새 경로가 반영된다', () async {
      // Arrange
      final newDir = Directory.systemTemp.createTempSync('folio_cache_new_');
      try {
        // Act
        cacheManager.setStorageDir(newDir.path);
        final path = cacheManager.localPath(
          bookId: 'book1',
          ext: 'pdf',
          type: CacheType.book,
        );
        // Assert
        expect(path, startsWith(newDir.path));
      } finally {
        newDir.deleteSync(recursive: true);
      }
    });

    test('캐시를 삭제하면 파일이 제거된다', () async {
      // Arrange
      final path = '${tempDir.path}/folio/books/book1.pdf';
      File(path).createSync(recursive: true);
      // Act
      await cacheManager.delete(
        bookId: 'book1',
        ext: 'pdf',
        type: CacheType.book,
      );
      // Assert
      expect(File(path).existsSync(), isFalse);
    });
  });
}
