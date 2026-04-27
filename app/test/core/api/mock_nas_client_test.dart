import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/api/mock_nas_client.dart';
import 'package:app/core/api/nas_client.dart';
import 'package:app/core/file_detector.dart';
import 'package:app/core/file_model.dart';

void main() {
  group('MockNasClient', () {
    late NasClient client;

    setUp(() {
      client = MockNasClient();
    });

    group('getFiles', () {
      test('루트 경로에서 파일 목록을 반환한다', () async {
        // Arrange + Act
        final result = await client.getFiles('/');
        // Assert
        expect(result, isA<List<FileModel>>());
        expect(result, isNotEmpty);
      });

      test('반환된 파일은 FileModel 타입이다', () async {
        final result = await client.getFiles('/');
        expect(result.first, isA<FileModel>());
      });

      test('반환된 파일의 fileType은 pdf 또는 epub 또는 unknown이다', () async {
        final result = await client.getFiles('/');
        for (final file in result) {
          expect(FileType.values, contains(file.fileType));
        }
      });

      test('존재하지 않는 경로는 빈 목록을 반환한다', () async {
        final result = await client.getFiles('/not/exist');
        expect(result, isEmpty);
      });

      test('pdf 경로에서는 pdf 파일만 반환한다', () async {
        final result = await client.getFiles('/pdf');
        expect(result, isNotEmpty);
        expect(result.every((f) => f.fileType == FileType.pdf), isTrue);
      });

      test('epub 경로에서는 epub 파일만 반환한다', () async {
        final result = await client.getFiles('/epub');
        expect(result, isNotEmpty);
        expect(result.every((f) => f.fileType == FileType.epub), isTrue);
      });
    });

    group('getFile', () {
      test('경로에 해당하는 FileModel을 반환한다', () async {
        // Arrange
        final files = await client.getFiles('/');
        final target = files.first;
        // Act
        final result = await client.getFile(target.path);
        // Assert
        expect(result, target);
      });

      test('존재하지 않는 경로는 null을 반환한다', () async {
        final result = await client.getFile('/not/exist/file.pdf');
        expect(result, isNull);
      });
    });
  });
}
