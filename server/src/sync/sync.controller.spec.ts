/**
 * @description SyncController 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see SyncController
 */
import { Test, TestingModule } from '@nestjs/testing';
import { SyncController } from './sync.controller';
import { BookSyncService } from './book-sync.service';

const mockBookSyncService = { sync: jest.fn() };

describe('SyncController', () => {
  let controller: SyncController;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [SyncController],
      providers: [{ provide: BookSyncService, useValue: mockBookSyncService }],
    }).compile();

    controller = module.get<SyncController>(SyncController);
  });

  describe('POST /v1/sync', () => {
    it('sync() 결과를 반환한다', async () => {
      // Arrange
      mockBookSyncService.sync.mockResolvedValue({
        added: 2,
        updated: 1,
        deleted: 0,
      });
      // Act
      const result = await controller.sync();
      // Assert
      expect(mockBookSyncService.sync).toHaveBeenCalledTimes(1);
      expect(result).toEqual({ added: 2, updated: 1, deleted: 0 });
    });
  });
});
