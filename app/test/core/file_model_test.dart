import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/file_model.dart';
import 'package:app/core/file_detector.dart';

void main() {
  group('FileModel', () {
    group('생성', () {
      test('필수 필드만으로 생성된다', () {
        // Arrange + Act
        final model = FileModel(
          id: 'file-001',
          name: 'book.pdf',
          type: FileType.pdf,
          path: '/nas/docs/book.pdf',
        );
        // Assert
        expect(model.id, 'file-001');
        expect(model.name, 'book.pdf');
        expect(model.type, FileType.pdf);
        expect(model.path, '/nas/docs/book.pdf');
        expect(model.lastOpenedAt, isNull);
      });

      test('lastOpenedAt을 포함해서 생성된다', () {
        final openedAt = DateTime(2026, 4, 27, 10, 0);
        final model = FileModel(
          id: 'file-002',
          name: 'novel.epub',
          type: FileType.epub,
          path: '/nas/books/novel.epub',
          lastOpenedAt: openedAt,
        );
        expect(model.lastOpenedAt, openedAt);
      });
    });

    group('동등성', () {
      test('같은 값이면 동등하다', () {
        final a = FileModel(
          id: 'file-001',
          name: 'book.pdf',
          type: FileType.pdf,
          path: '/nas/docs/book.pdf',
        );
        final b = FileModel(
          id: 'file-001',
          name: 'book.pdf',
          type: FileType.pdf,
          path: '/nas/docs/book.pdf',
        );
        expect(a, b);
      });

      test('id가 다르면 동등하지 않다', () {
        final a = FileModel(
          id: 'file-001',
          name: 'book.pdf',
          type: FileType.pdf,
          path: '/nas/docs/book.pdf',
        );
        final b = FileModel(
          id: 'file-002',
          name: 'book.pdf',
          type: FileType.pdf,
          path: '/nas/docs/book.pdf',
        );
        expect(a, isNot(b));
      });

      test('path가 다르면 동등하지 않다', () {
        final a = FileModel(
          id: 'file-001',
          name: 'book.pdf',
          type: FileType.pdf,
          path: '/nas/docs/book.pdf',
        );
        final b = FileModel(
          id: 'file-001',
          name: 'book.pdf',
          type: FileType.pdf,
          path: '/nas/other/book.pdf',
        );
        expect(a, isNot(b));
      });
    });

    group('JSON 변환', () {
      test('fromJson으로 FileModel을 생성한다', () {
        final json = {
          'id': 'file-001',
          'name': 'novel.epub',
          'type': 'epub',
          'path': '/nas/books/novel.epub',
          'lastOpenedAt': null,
        };
        final model = FileModel.fromJson(json);
        expect(model.id, 'file-001');
        expect(model.name, 'novel.epub');
        expect(model.type, FileType.epub);
        expect(model.path, '/nas/books/novel.epub');
        expect(model.lastOpenedAt, isNull);
      });

      test('lastOpenedAt이 있는 JSON을 변환한다', () {
        final json = {
          'id': 'file-002',
          'name': 'book.pdf',
          'type': 'pdf',
          'path': '/nas/docs/book.pdf',
          'lastOpenedAt': '2026-04-27T10:00:00.000',
        };
        final model = FileModel.fromJson(json);
        expect(model.lastOpenedAt, DateTime(2026, 4, 27, 10, 0));
      });

      test('toJson으로 Map을 반환한다', () {
        final model = FileModel(
          id: 'file-001',
          name: 'novel.epub',
          type: FileType.epub,
          path: '/nas/books/novel.epub',
        );
        final json = model.toJson();
        expect(json['id'], 'file-001');
        expect(json['name'], 'novel.epub');
        expect(json['type'], 'epub');
        expect(json['path'], '/nas/books/novel.epub');
        expect(json['lastOpenedAt'], isNull);
      });

      test('fromJson → toJson 왕복 변환이 일치한다', () {
        final json = {
          'id': 'file-001',
          'name': 'book.pdf',
          'type': 'pdf',
          'path': '/nas/docs/book.pdf',
          'lastOpenedAt': null,
        };
        expect(FileModel.fromJson(json).toJson(), json);
      });

      test('type이 알 수 없는 값이면 unknown을 반환한다', () {
        final json = {
          'id': 'file-003',
          'name': 'video.mp4',
          'type': 'video',
          'path': '/nas/videos/video.mp4',
          'lastOpenedAt': null,
        };
        final model = FileModel.fromJson(json);
        expect(model.type, FileType.unknown);
      });
    });
  });
}
