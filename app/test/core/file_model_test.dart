import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/file_model.dart';
import 'package:app/core/file_detector.dart';

void main() {
  group('FileModel', () {
    group('생성', () {
      test('모든 필드가 정상적으로 할당된다', () {
        // Arrange + Act
        const model = FileModel(
          name: 'book.pdf',
          path: '/nas/docs/book.pdf',
          mimeType: 'application/pdf',
          size: 1024,
          fileType: FileType.pdf,
        );
        // Assert
        expect(model.name, 'book.pdf');
        expect(model.path, '/nas/docs/book.pdf');
        expect(model.mimeType, 'application/pdf');
        expect(model.size, 1024);
        expect(model.fileType, FileType.pdf);
      });
    });

    group('동등성', () {
      test('같은 값이면 동등하다', () {
        const a = FileModel(
          name: 'book.pdf',
          path: '/nas/docs/book.pdf',
          mimeType: 'application/pdf',
          size: 1024,
          fileType: FileType.pdf,
        );
        const b = FileModel(
          name: 'book.pdf',
          path: '/nas/docs/book.pdf',
          mimeType: 'application/pdf',
          size: 1024,
          fileType: FileType.pdf,
        );
        expect(a, b);
      });

      test('name이 다르면 동등하지 않다', () {
        const a = FileModel(
          name: 'book.pdf',
          path: '/nas/docs/book.pdf',
          mimeType: 'application/pdf',
          size: 1024,
          fileType: FileType.pdf,
        );
        const b = FileModel(
          name: 'other.pdf',
          path: '/nas/docs/book.pdf',
          mimeType: 'application/pdf',
          size: 1024,
          fileType: FileType.pdf,
        );
        expect(a, isNot(b));
      });

      test('path가 다르면 동등하지 않다', () {
        const a = FileModel(
          name: 'book.pdf',
          path: '/nas/docs/book.pdf',
          mimeType: 'application/pdf',
          size: 1024,
          fileType: FileType.pdf,
        );
        const b = FileModel(
          name: 'book.pdf',
          path: '/nas/other/book.pdf',
          mimeType: 'application/pdf',
          size: 1024,
          fileType: FileType.pdf,
        );
        expect(a, isNot(b));
      });
    });

    group('JSON 변환', () {
      test('fromJson으로 FileModel을 생성한다', () {
        // Arrange
        final json = {
          'name': 'novel.epub',
          'path': '/nas/books/novel.epub',
          'mimeType': 'application/epub+zip',
          'size': 2048,
          'fileType': 'epub',
        };
        // Act
        final model = FileModel.fromJson(json);
        // Assert
        expect(model.name, 'novel.epub');
        expect(model.path, '/nas/books/novel.epub');
        expect(model.mimeType, 'application/epub+zip');
        expect(model.size, 2048);
        expect(model.fileType, FileType.epub);
      });

      test('toJson으로 Map을 반환한다', () {
        const model = FileModel(
          name: 'novel.epub',
          path: '/nas/books/novel.epub',
          mimeType: 'application/epub+zip',
          size: 2048,
          fileType: FileType.epub,
        );
        final json = model.toJson();
        expect(json['name'], 'novel.epub');
        expect(json['path'], '/nas/books/novel.epub');
        expect(json['mimeType'], 'application/epub+zip');
        expect(json['size'], 2048);
        expect(json['fileType'], 'epub');
      });

      test('fromJson → toJson 왕복 변환이 일치한다', () {
        final json = {
          'name': 'book.pdf',
          'path': '/nas/docs/book.pdf',
          'mimeType': 'application/pdf',
          'size': 1024,
          'fileType': 'pdf',
        };
        expect(FileModel.fromJson(json).toJson(), json);
      });

      test('fileType이 unknown인 JSON도 변환된다', () {
        final json = {
          'name': 'readme.txt',
          'path': '/nas/docs/readme.txt',
          'mimeType': 'text/plain',
          'size': 512,
          'fileType': 'unknown',
        };
        final model = FileModel.fromJson(json);
        expect(model.fileType, FileType.unknown);
      });

      test('fileType이 알 수 없는 값이면 unknown을 반환한다', () {
        final json = {
          'name': 'video.mp4',
          'path': '/nas/videos/video.mp4',
          'mimeType': 'video/mp4',
          'size': 4096,
          'fileType': 'video',
        };
        final model = FileModel.fromJson(json);
        expect(model.fileType, FileType.unknown);
      });

      test('size가 double로 오면 int로 변환된다', () {
        final json = {
          'name': 'book.pdf',
          'path': '/nas/docs/book.pdf',
          'mimeType': 'application/pdf',
          'size': 1024.0,
          'fileType': 'pdf',
        };
        final model = FileModel.fromJson(json);
        expect(model.size, 1024);
      });
    });
  });
}
