/**
 * @description AppController 헬스체크 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AppController
 */
import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';

describe('AppController', () => {
  let controller: AppController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
    }).compile();

    controller = module.get<AppController>(AppController);
  });

  describe('GET /v1/health', () => {
    it('status: ok를 반환한다', () => {
      // Arrange & Act
      const result = controller.health();
      // Assert
      expect(result).toEqual({ status: 'ok' });
    });
  });
});
