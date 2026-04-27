/**
 * @description SyncController JWT 가드 적용 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see SyncController
 */
import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import request from 'supertest';
import authConfig from '../config/auth.config';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { JwtStrategy } from '../auth/jwt.strategy';
import { BookSyncService } from './book-sync.service';
import { SyncController } from './sync.controller';

const TEST_SECRET = 'test-secret';
const mockBookSyncService = { sync: jest.fn() };

describe('SyncController — JWT 가드', () => {
  let app: INestApplication;
  let jwtService: JwtService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      imports: [
        PassportModule.register({ defaultStrategy: 'jwt' }),
        JwtModule.register({ secret: TEST_SECRET }),
      ],
      controllers: [SyncController],
      providers: [
        { provide: BookSyncService, useValue: mockBookSyncService },
        { provide: authConfig.KEY, useValue: { jwtSecret: TEST_SECRET, jwtExpiresIn: '1h' } },
        JwtStrategy,
        JwtAuthGuard,
      ],
    }).compile();

    app = module.createNestApplication();
    await app.init();
    jwtService = module.get<JwtService>(JwtService);
  });

  afterEach(() => app.close());

  describe('POST /v1/sync', () => {
    it('토큰 없으면 401을 반환한다', () => {
      return request(app.getHttpServer())
        .post('/v1/sync')
        .expect(401);
    });

    it('유효한 토큰이면 정상 응답한다', async () => {
      // Arrange
      mockBookSyncService.sync.mockResolvedValue({ added: 1, updated: 0, deleted: 0 });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      return request(app.getHttpServer())
        .post('/v1/sync')
        .set('Authorization', `Bearer ${token}`)
        .expect(201);
    });
  });
});
