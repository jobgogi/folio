/**
 * @description BooksController 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksController
 */
import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { BooksController } from './books.controller';
import { BooksService } from './books.service';

const mockBooksService = {
  findAll: jest.fn(),
  findOne: jest.fn(),
  update: jest.fn(),
  open: jest.fn(),
};

const book = {
  id: 'uuid-1',
  name: 'book.pdf',
  title: 'Clean Code',
  author: 'Robert C. Martin',
  type: 'PDF',
  path: '/nas/book.pdf',
  size: 1024,
  lastSyncAt: new Date(),
  createdAt: new Date(),
  updatedAt: new Date(),
};

describe('BooksController', () => {
  let controller: BooksController;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [BooksController],
      providers: [{ provide: BooksService, useValue: mockBooksService }],
    }).compile();

    controller = module.get<BooksController>(BooksController);
  });

  describe('GET /v1/books', () => {
    it('페이징된 Book 목록과 meta를 반환한다', async () => {
      // Arrange
      const paged = {
        data: [book],
        meta: { total: 1, page: 1, limit: 20, totalPages: 1 },
      };
      mockBooksService.findAll.mockResolvedValue(paged);
      // Act
      const result = await controller.findAll({
        page: 1,
        limit: 20,
        sort: 'recent_opened',
      });
      // Assert
      expect(mockBooksService.findAll).toHaveBeenCalledWith({
        page: 1,
        limit: 20,
        sort: 'recent_opened',
      });
      expect(result).toEqual(paged);
    });
  });

  describe('GET /v1/books/:id', () => {
    it('단일 Book을 반환한다', async () => {
      // Arrange
      mockBooksService.findOne.mockResolvedValue(book);
      // Act
      const result = await controller.findOne('uuid-1');
      // Assert
      expect(mockBooksService.findOne).toHaveBeenCalledWith('uuid-1');
      expect(result).toEqual(book);
    });

    it('존재하지 않는 id이면 NotFoundException을 던진다', async () => {
      // Arrange
      mockBooksService.findOne.mockRejectedValue(new NotFoundException());
      // Act & Assert
      await expect(controller.findOne('no-such-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('PATCH /v1/books/:id', () => {
    it('수정된 Book을 반환한다', async () => {
      // Arrange
      const updated = { ...book, title: 'Refactoring' };
      mockBooksService.update.mockResolvedValue(updated);
      // Act
      const result = await controller.update('uuid-1', {
        title: 'Refactoring',
      });
      // Assert
      expect(mockBooksService.update).toHaveBeenCalledWith('uuid-1', {
        title: 'Refactoring',
      });
      expect(result).toEqual(updated);
    });

    it('일부 필드만 수정해도 반영된다', async () => {
      // Arrange
      const updated = { ...book, author: '마틴 파울러' };
      mockBooksService.update.mockResolvedValue(updated);
      // Act
      const result = await controller.update('uuid-1', {
        author: '마틴 파울러',
      });
      // Assert
      expect(result.author).toBe('마틴 파울러');
    });

    it('readingDirection 수정이 반영된다', async () => {
      // Arrange
      const updated = { ...book, readingDirection: 'RTL' };
      mockBooksService.update.mockResolvedValue(updated);
      // Act
      const result = await controller.update('uuid-1', {
        readingDirection: 'RTL',
      });
      // Assert
      expect(result.readingDirection).toBe('RTL');
    });

    it('존재하지 않는 id이면 NotFoundException을 던진다', async () => {
      // Arrange
      mockBooksService.update.mockRejectedValue(new NotFoundException());
      // Act & Assert
      await expect(
        controller.update('no-such-id', { title: 'X' }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe('PATCH /v1/books/:id/open', () => {
    it('lastOpenedAt이 갱신된 Book을 반환한다', async () => {
      // Arrange
      const opened = { ...book, lastOpenedAt: new Date() };
      mockBooksService.open.mockResolvedValue(opened);
      // Act
      const result = await controller.open('uuid-1');
      // Assert
      expect(mockBooksService.open).toHaveBeenCalledWith('uuid-1');
      expect(result.lastOpenedAt).toBeDefined();
    });

    it('존재하지 않는 id이면 NotFoundException을 던진다', async () => {
      // Arrange
      mockBooksService.open.mockRejectedValue(new NotFoundException());
      // Act & Assert
      await expect(controller.open('no-such-id')).rejects.toThrow(
        NotFoundException,
      );
    });
  });
});
