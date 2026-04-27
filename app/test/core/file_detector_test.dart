import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/file_detector.dart';

void main() {
  group('FileDetector', () {
    late FileDetector detector;

    setUp(() {
      detector = FileDetector();
    });

    group('PDF 감지', () {
      test('MIME 타입이 application/pdf이면 pdf를 반환한다', () {
        // Arrange + Act
        final result = detector.detect(mimeType: 'application/pdf', fileName: 'book.pdf');
        // Assert
        expect(result, FileType.pdf);
      });

      test('확장자가 .pdf이면 pdf를 반환한다', () {
        final result = detector.detect(mimeType: 'application/octet-stream', fileName: 'document.pdf');
        expect(result, FileType.pdf);
      });
    });

    group('ePub 감지', () {
      test('MIME 타입이 application/epub+zip이면 epub를 반환한다', () {
        final result = detector.detect(mimeType: 'application/epub+zip', fileName: 'novel.epub');
        expect(result, FileType.epub);
      });

      test('확장자가 .epub이면 epub를 반환한다', () {
        final result = detector.detect(mimeType: 'application/octet-stream', fileName: 'novel.epub');
        expect(result, FileType.epub);
      });
    });

    group('지원하지 않는 타입', () {
      test('text/plain이면 unknown을 반환한다', () {
        final result = detector.detect(mimeType: 'text/plain', fileName: 'readme.txt');
        expect(result, FileType.unknown);
      });

      test('확장자가 없으면 unknown을 반환한다', () {
        final result = detector.detect(mimeType: 'application/octet-stream', fileName: 'noextension');
        expect(result, FileType.unknown);
      });

      test('빈 문자열 파일명이면 unknown을 반환한다', () {
        final result = detector.detect(mimeType: '', fileName: '');
        expect(result, FileType.unknown);
      });
    });

    group('MIME 우선순위', () {
      test('MIME이 pdf이면 확장자가 epub여도 pdf를 반환한다', () {
        final result = detector.detect(mimeType: 'application/pdf', fileName: 'wrong.epub');
        expect(result, FileType.pdf);
      });

      test('MIME이 epub이면 확장자가 pdf여도 epub를 반환한다', () {
        final result = detector.detect(mimeType: 'application/epub+zip', fileName: 'wrong.pdf');
        expect(result, FileType.epub);
      });
    });
  });
}
