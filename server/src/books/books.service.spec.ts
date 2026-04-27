/**
 * @description BooksService 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksService
 */
import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import * as fs from 'fs/promises';
import { PrismaService } from '../prisma/prisma.service';
import { BooksService } from './books.service';

jest.mock('fs/promises');
const mockFs = fs as jest.Mocked<typeof fs>;

const mockPrisma = {
  book: {
    findUnique: jest.fn(),
  },
};

const pdfBook = {
  id: 'uuid-1',
  title: 'Clean Code',
  path: '/mnt/nas/clean_code.pdf',
  type: 'PDF',
};

const epubBook = {
  id: 'uuid-2',
  title: 'Dune',
  path: '/mnt/nas/dune.epub',
  type: 'EPUB',
};

describe('BooksService', () => {
  let service: BooksService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BooksService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<BooksService>(BooksService);
  });

  describe('download', () => {
    it('PDF 파일을 반환하고 contentType이 application/pdf이다', async () => {
      // Arrange
      mockPrisma.book.findUnique.mockResolvedValue(pdfBook);
      mockFs.readFile.mockResolvedValue(Buffer.from('pdf-data') as any);
      // Act
      const result = await service.download('uuid-1');
      // Assert
      expect(result.buffer).toBeInstanceOf(Buffer);
      expect(result.contentType).toBe('application/pdf');
      expect(result.filename).toBe('clean_code.pdf');
    });

    it('ePub 파일을 반환하고 contentType이 application/epub+zip이다', async () => {
      // Arrange
      mockPrisma.book.findUnique.mockResolvedValue(epubBook);
      mockFs.readFile.mockResolvedValue(Buffer.from('epub-data') as any);
      // Act
      const result = await service.download('uuid-2');
      // Assert
      expect(result.buffer).toBeInstanceOf(Buffer);
      expect(result.contentType).toBe('application/epub+zip');
      expect(result.filename).toBe('dune.epub');
    });

    it('존재하지 않는 id이면 NotFoundException을 던진다', async () => {
      // Arrange
      mockPrisma.book.findUnique.mockResolvedValue(null);
      // Act & Assert
      await expect(service.download('not-exist')).rejects.toThrow(NotFoundException);
    });

    it('NAS 경로에 파일이 없으면 NotFoundException을 던진다', async () => {
      // Arrange
      mockPrisma.book.findUnique.mockResolvedValue(pdfBook);
      mockFs.readFile.mockRejectedValue(new Error('ENOENT'));
      // Act & Assert
      await expect(service.download('uuid-1')).rejects.toThrow(NotFoundException);
    });
  });
});
