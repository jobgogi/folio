/**
 * @description BooksService 썸네일 다운로드 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksService
 */
import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import * as fs from 'fs/promises';
import nasConfig from '../config/nas.config';
import { PrismaService } from '../prisma/prisma.service';
import { BooksService } from './books.service';

jest.mock('fs/promises');
const mockFs = fs as jest.Mocked<typeof fs>;

const mockPrisma = {
  book: {
    findUnique: jest.fn(),
    update: jest.fn(),
  },
};

const MOCK_NAS_PATH = '/mnt/nas';

describe('BooksService — downloadThumbnail', () => {
  let service: BooksService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        BooksService,
        { provide: nasConfig.KEY, useValue: { mountPath: MOCK_NAS_PATH } },
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<BooksService>(BooksService);
  });

  it('jpg 썸네일을 읽고 buffer와 ext를 반환한다', async () => {
    // Arrange
    mockPrisma.book.findUnique.mockResolvedValue({
      id: 'uuid-1',
      thumbnail: `${MOCK_NAS_PATH}/.thumbnails/uuid-1.jpg`,
    });
    mockFs.readFile.mockResolvedValue(Buffer.from('imgdata') as any);
    // Act
    const result = await service.downloadThumbnail('uuid-1');
    // Assert
    expect(result.buffer).toBeInstanceOf(Buffer);
    expect(result.ext).toBe('jpg');
  });

  it('png 썸네일을 읽고 buffer와 ext를 반환한다', async () => {
    // Arrange
    mockPrisma.book.findUnique.mockResolvedValue({
      id: 'uuid-1',
      thumbnail: `${MOCK_NAS_PATH}/.thumbnails/uuid-1.png`,
    });
    mockFs.readFile.mockResolvedValue(Buffer.from('imgdata') as any);
    // Act
    const result = await service.downloadThumbnail('uuid-1');
    // Assert
    expect(result.buffer).toBeInstanceOf(Buffer);
    expect(result.ext).toBe('png');
  });

  it('존재하지 않는 id이면 NotFoundException을 던진다', async () => {
    // Arrange
    mockPrisma.book.findUnique.mockResolvedValue(null);
    // Act & Assert
    await expect(service.downloadThumbnail('not-exist')).rejects.toThrow(NotFoundException);
  });

  it('thumbnail 필드가 null이면 NotFoundException을 던진다', async () => {
    // Arrange
    mockPrisma.book.findUnique.mockResolvedValue({ id: 'uuid-1', thumbnail: null });
    // Act & Assert
    await expect(service.downloadThumbnail('uuid-1')).rejects.toThrow(NotFoundException);
  });

  it('파일이 존재하지 않으면 NotFoundException을 던진다', async () => {
    // Arrange
    mockPrisma.book.findUnique.mockResolvedValue({
      id: 'uuid-1',
      thumbnail: `${MOCK_NAS_PATH}/.thumbnails/uuid-1.jpg`,
    });
    mockFs.readFile.mockRejectedValue(new Error('ENOENT'));
    // Act & Assert
    await expect(service.downloadThumbnail('uuid-1')).rejects.toThrow(NotFoundException);
  });
});
