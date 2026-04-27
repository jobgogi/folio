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

      test('epub 파일을 경로로 조회한다', () async {
        final result = await client.getFile('/epub/novel.epub');
        expect(result, isNotNull);
        expect(result!.fileType, FileType.epub);
      });

      test('존재하지 않는 경로는 null을 반환한다', () async {
        final result = await client.getFile('/not/exist/file.pdf');
        expect(result, isNull);
      });
    });

    group('생성자 주입', () {
      test('커스텀 파일 목록을 주입하면 해당 목록을 반환한다', () async {
        // Arrange
        const customFiles = [
          FileModel(
            name: 'custom.pdf',
            path: '/custom/custom.pdf',
            mimeType: 'application/pdf',
            size: 512,
            fileType: FileType.pdf,
          ),
        ];
        final customClient = MockNasClient(files: customFiles);
        // Act
        final result = await customClient.getFiles('/');
        // Assert
        expect(result.length, 1);
        expect(result.first.name, 'custom.pdf');
      });

      test('주입된 파일을 경로로 조회할 수 있다', () async {
        const customFiles = [
          FileModel(
            name: 'custom.epub',
            path: '/custom/custom.epub',
            mimeType: 'application/epub+zip',
            size: 512,
            fileType: FileType.epub,
          ),
        ];
        final customClient = MockNasClient(files: customFiles);
        final result = await customClient.getFile('/custom/custom.epub');
        expect(result, isNotNull);
        expect(result!.fileType, FileType.epub);
      });
    });
  });
}
