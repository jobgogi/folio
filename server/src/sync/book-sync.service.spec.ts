/**
 * @description BookSyncService 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BookSyncService
 */
import { Test, TestingModule } from '@nestjs/testing';
import { BookSyncService } from './book-sync.service';
import { BookScanService } from './book-scan.service';
import { BookMetaExtractService } from './book-meta-extract.service';
import { PrismaService } from '../prisma/prisma.service';
import nasConfig from '../config/nas.config';

const mockScanService = { scan: jest.fn() };
const mockMetaService = { extract: jest.fn() };
const mockPrisma = {
  book: {
    findMany: jest.fn(),
    upsert: jest.fn(),
    update: jest.fn(),
    deleteMany: jest.fn(),
  },
};
const mockNasConfig = { mountPath: '/nas' };

const scannedPdf = { name: 'book.pdf', path: '/nas/book.pdf', size: 1024, type: 'PDF' as const };
const dbBook = { id: 'uuid-1', path: '/nas/book.pdf', name: 'book.pdf', type: 'PDF' };

describe('BookSyncService', () => {
  let service: BookSyncService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BookSyncService,
        { provide: BookScanService, useValue: mockScanService },
        { provide: BookMetaExtractService, useValue: mockMetaService },
        { provide: PrismaService, useValue: mockPrisma },
        { provide: nasConfig.KEY, useValue: mockNasConfig },
      ],
    }).compile();

    service = module.get<BookSyncService>(BookSyncService);
  });

  describe('sync', () => {
    it('신규 파일을 Book으로 생성하고 added 카운트를 반환한다', async () => {
      // Arrange
      mockScanService.scan.mockResolvedValue([scannedPdf]);
      mockPrisma.book.findMany.mockResolvedValue([]);
      mockMetaService.extract.mockResolvedValue({ title: 'Book Title' });
      mockPrisma.book.upsert.mockResolvedValue({});
      // Act
      const result = await service.sync();
      // Assert
      expect(mockPrisma.book.upsert).toHaveBeenCalledTimes(1);
      expect(result).toEqual({ added: 1, updated: 0, deleted: 0 });
    });

    it('메타데이터 추출 성공 시 Book 필드에 반영한다', async () => {
      // Arrange
      mockScanService.scan.mockResolvedValue([scannedPdf]);
      mockPrisma.book.findMany.mockResolvedValue([]);
      mockMetaService.extract.mockResolvedValue({
        title: 'Clean Code',
        author: 'Robert C. Martin',
        publisher: 'Prentice Hall',
      });
      mockPrisma.book.upsert.mockResolvedValue({});
      // Act
      await service.sync();
      // Assert
      expect(mockPrisma.book.upsert).toHaveBeenCalledWith(
        expect.objectContaining({
          create: expect.objectContaining({
            title: 'Clean Code',
            author: 'Robert C. Martin',
            publisher: 'Prentice Hall',
          }),
        }),
      );
    });

    it('메타데이터 추출 실패(fallback) 시 파일명이 title로 저장된다', async () => {
      // Arrange
      mockScanService.scan.mockResolvedValue([scannedPdf]);
      mockPrisma.book.findMany.mockResolvedValue([]);
      mockMetaService.extract.mockResolvedValue({ title: 'book' });
      mockPrisma.book.upsert.mockResolvedValue({});
      // Act
      await service.sync();
      // Assert
      expect(mockPrisma.book.upsert).toHaveBeenCalledWith(
        expect.objectContaining({
          create: expect.objectContaining({ title: 'book' }),
        }),
      );
    });

    it('기존 파일은 lastSyncAt을 업데이트하고 updated 카운트를 반환한다', async () => {
      // Arrange
      mockScanService.scan.mockResolvedValue([scannedPdf]);
      mockPrisma.book.findMany.mockResolvedValue([dbBook]);
      mockPrisma.book.update.mockResolvedValue({});
      // Act
      const result = await service.sync();
      // Assert
      expect(mockPrisma.book.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'uuid-1' },
          data: expect.objectContaining({ lastSyncAt: expect.any(Date) }),
        }),
      );
      expect(result).toEqual({ added: 0, updated: 1, deleted: 0 });
    });

    it('스캔에서 사라진 파일은 DB에서 삭제하고 deleted 카운트를 반환한다', async () => {
      // Arrange
      mockScanService.scan.mockResolvedValue([]);
      mockPrisma.book.findMany.mockResolvedValue([dbBook]);
      mockPrisma.book.deleteMany.mockResolvedValue({ count: 1 });
      // Act
      const result = await service.sync();
      // Assert
      expect(mockPrisma.book.deleteMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: { in: ['uuid-1'] } },
        }),
      );
      expect(result).toEqual({ added: 0, updated: 0, deleted: 1 });
    });

    it('스캔 결과와 DB가 모두 비어있으면 { added: 0, updated: 0, deleted: 0 }을 반환한다', async () => {
      // Arrange
      mockScanService.scan.mockResolvedValue([]);
      mockPrisma.book.findMany.mockResolvedValue([]);
      // Act
      const result = await service.sync();
      // Assert
      expect(result).toEqual({ added: 0, updated: 0, deleted: 0 });
    });

    it('동일 경로가 중복 스캔되면 upsert를 한 번만 호출한다', async () => {
      // Arrange — 같은 path를 가진 파일이 스캔 결과에 두 번 포함
      mockScanService.scan.mockResolvedValue([scannedPdf, scannedPdf]);
      mockPrisma.book.findMany.mockResolvedValue([]);
      mockMetaService.extract.mockResolvedValue({ title: 'book' });
      mockPrisma.book.upsert.mockResolvedValue({});
      // Act
      const result = await service.sync();
      // Assert
      expect(mockPrisma.book.upsert).toHaveBeenCalledTimes(1);
      expect(result).toEqual({ added: 1, updated: 0, deleted: 0 });
    });
  });
});
