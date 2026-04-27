/**
 * @description BooksService 썸네일 업로드 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksService
 */
import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, NotFoundException } from '@nestjs/common';
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

describe('BooksService — uploadThumbnail', () => {
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

  const makeFile = (name: string, size: number): Express.Multer.File =>
    ({ originalname: name, size, buffer: Buffer.from('imgdata') } as Express.Multer.File);

  it('jpg 파일을 업로드하고 thumbnail 경로를 반영한다', async () => {
    // Arrange
    const file = makeFile('cover.jpg', 1024 * 100);
    mockPrisma.book.findUnique.mockResolvedValue({ id: 'uuid-1', title: 'Clean Code', thumbnail: null });
    mockFs.mkdir.mockResolvedValue(undefined);
    mockFs.writeFile.mockResolvedValue(undefined);
    mockPrisma.book.update.mockResolvedValue({
      id: 'uuid-1', thumbnail: `${MOCK_NAS_PATH}/.thumbnails/uuid-1.jpg`,
    });
    // Act
    const result = await service.uploadThumbnail('uuid-1', file);
    // Assert
    expect(result.thumbnailPath).toContain('uuid-1.jpg');
  });

  it('png 파일을 업로드하고 thumbnail 경로를 반영한다', async () => {
    // Arrange
    const file = makeFile('cover.png', 1024 * 100);
    mockPrisma.book.findUnique.mockResolvedValue({ id: 'uuid-1', title: 'Clean Code', thumbnail: null });
    mockFs.mkdir.mockResolvedValue(undefined);
    mockFs.writeFile.mockResolvedValue(undefined);
    mockPrisma.book.update.mockResolvedValue({
      id: 'uuid-1', thumbnail: `${MOCK_NAS_PATH}/.thumbnails/uuid-1.png`,
    });
    // Act
    const result = await service.uploadThumbnail('uuid-1', file);
    // Assert
    expect(result.thumbnailPath).toContain('uuid-1.png');
  });

  it('허용되지 않는 확장자면 BadRequestException을 던진다', async () => {
    // Arrange
    const file = makeFile('cover.gif', 1024 * 100);
    mockPrisma.book.findUnique.mockResolvedValue({ id: 'uuid-1', title: 'Clean Code', thumbnail: null });
    // Act & Assert
    await expect(service.uploadThumbnail('uuid-1', file)).rejects.toThrow(BadRequestException);
  });

  it('5MB 초과 파일이면 BadRequestException을 던진다', async () => {
    // Arrange
    const file = makeFile('cover.jpg', 1024 * 1024 * 6);
    mockPrisma.book.findUnique.mockResolvedValue({ id: 'uuid-1', title: 'Clean Code', thumbnail: null });
    // Act & Assert
    await expect(service.uploadThumbnail('uuid-1', file)).rejects.toThrow(BadRequestException);
  });

  it('기존 썸네일이 있으면 덮어쓴다', async () => {
    // Arrange
    const file = makeFile('cover.png', 1024 * 100);
    mockPrisma.book.findUnique.mockResolvedValue({
      id: 'uuid-1', title: 'Clean Code',
      thumbnail: `${MOCK_NAS_PATH}/.thumbnails/uuid-1.jpg`,
    });
    mockFs.rm.mockResolvedValue(undefined);
    mockFs.mkdir.mockResolvedValue(undefined);
    mockFs.writeFile.mockResolvedValue(undefined);
    mockPrisma.book.update.mockResolvedValue({
      id: 'uuid-1', thumbnail: `${MOCK_NAS_PATH}/.thumbnails/uuid-1.png`,
    });
    // Act
    const result = await service.uploadThumbnail('uuid-1', file);
    // Assert
    expect(mockFs.rm).toHaveBeenCalled();
    expect(result.thumbnailPath).toContain('uuid-1.png');
  });

  it('존재하지 않는 Book id이면 NotFoundException을 던진다', async () => {
    // Arrange
    const file = makeFile('cover.jpg', 1024 * 100);
    mockPrisma.book.findUnique.mockResolvedValue(null);
    // Act & Assert
    await expect(service.uploadThumbnail('uuid-1', file)).rejects.toThrow(NotFoundException);
  });
});
