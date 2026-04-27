/**
 * @description BookMetaExtractService 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BookMetaExtractService
 */
import { Test, TestingModule } from '@nestjs/testing';
import { BookMetaExtractService } from './book-meta-extract.service';

describe('BookMetaExtractService', () => {
  let service: BookMetaExtractService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [BookMetaExtractService],
    }).compile();

    service = module.get<BookMetaExtractService>(BookMetaExtractService);
  });

  describe('extract — PDF', () => {
    it('PDF 메타데이터를 추출해 반환한다', async () => {
      // Arrange
      jest.spyOn(service as any, 'extractPdf').mockResolvedValue({
        title: 'Clean Code',
        author: 'Robert C. Martin',
      });
      // Act
      const result = await service.extract(
        '/nas/clean-code.pdf',
        'PDF',
        'clean-code.pdf',
      );
      // Assert
      expect(result).toEqual({
        title: 'Clean Code',
        author: 'Robert C. Martin',
      });
    });

    it('PDF 메타데이터 추출 실패 시 파일명을 title로 fallback한다', async () => {
      // Arrange
      jest
        .spyOn(service as any, 'extractPdf')
        .mockRejectedValue(new Error('파싱 실패'));
      // Act
      const result = await service.extract(
        '/nas/clean-code.pdf',
        'PDF',
        'clean-code.pdf',
      );
      // Assert
      expect(result).toEqual({ title: 'clean-code' });
    });
  });

  describe('extract — ePub', () => {
    it('ePub 메타데이터를 추출해 반환한다', async () => {
      // Arrange
      jest.spyOn(service as any, 'extractEpub').mockResolvedValue({
        title: '채식주의자',
        author: '한강',
        isbn: '9788936434120',
        publisher: '창비',
        publishedAt: new Date('2007-10-30'),
      });
      // Act
      const result = await service.extract(
        '/nas/vegetarian.epub',
        'EPUB',
        'vegetarian.epub',
      );
      // Assert
      expect(result).toEqual({
        title: '채식주의자',
        author: '한강',
        isbn: '9788936434120',
        publisher: '창비',
        publishedAt: new Date('2007-10-30'),
      });
    });

    it('ePub page-progression-direction이 ltr이면 LTR을 반환한다', async () => {
      // Arrange
      jest.spyOn(service as any, 'extractEpub').mockResolvedValue({
        title: '채식주의자',
        readingDirection: 'LTR',
      });
      // Act
      const result = await service.extract(
        '/nas/book.epub',
        'EPUB',
        'book.epub',
      );
      // Assert
      expect(result.readingDirection).toBe('LTR');
    });

    it('ePub page-progression-direction이 rtl이면 RTL을 반환한다', async () => {
      // Arrange
      jest.spyOn(service as any, 'extractEpub').mockResolvedValue({
        title: 'manga',
        readingDirection: 'RTL',
      });
      // Act
      const result = await service.extract(
        '/nas/manga.epub',
        'EPUB',
        'manga.epub',
      );
      // Assert
      expect(result.readingDirection).toBe('RTL');
    });

    it('ePub page-progression-direction이 ttb이면 TTB을 반환한다', async () => {
      // Arrange
      jest.spyOn(service as any, 'extractEpub').mockResolvedValue({
        title: 'vertical',
        readingDirection: 'TTB',
      });
      // Act
      const result = await service.extract(
        '/nas/vertical.epub',
        'EPUB',
        'vertical.epub',
      );
      // Assert
      expect(result.readingDirection).toBe('TTB');
    });

    it('ePub page-progression-direction이 없으면 readingDirection이 undefined이다', async () => {
      // Arrange
      jest.spyOn(service as any, 'extractEpub').mockResolvedValue({
        title: 'no-direction',
      });
      // Act
      const result = await service.extract(
        '/nas/no-dir.epub',
        'EPUB',
        'no-dir.epub',
      );
      // Assert
      expect(result.readingDirection).toBeUndefined();
    });

    it('ePub 메타데이터 추출 실패 시 파일명을 title로 fallback한다', async () => {
      // Arrange
      jest
        .spyOn(service as any, 'extractEpub')
        .mockRejectedValue(new Error('손상된 파일'));
      // Act
      const result = await service.extract(
        '/nas/broken.epub',
        'EPUB',
        'broken.epub',
      );
      // Assert
      expect(result).toEqual({ title: 'broken' });
    });
  });
});
