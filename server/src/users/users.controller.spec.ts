/**
 * @description UsersController 단위 테스트 (역할 기반 접근 제어)
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see UsersController
 */
import {
  CanActivate,
  ExecutionContext,
  INestApplication,
} from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { RolesGuard } from './guards/roles.guard';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

const mockUsersService = {
  createUser: jest.fn(),
  findAll: jest.fn(),
  deleteUser: jest.fn(),
  updatePassword: jest.fn(),
  uploadAvatar: jest.fn(),
  getAvatar: jest.fn(),
};

class MockJwtAuthGuard implements CanActivate {
  static mockUser: Record<string, unknown> = {
    sub: 'uuid-1',
    username: 'admin',
    role: 'ROOT',
  };
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest();
    req.user = MockJwtAuthGuard.mockUser;
    return true;
  }
}

describe('UsersController', () => {
  let app: INestApplication;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      controllers: [UsersController],
      providers: [{ provide: UsersService, useValue: mockUsersService }],
    })
      .overrideGuard(JwtAuthGuard)
      .useClass(MockJwtAuthGuard)
      .compile();

    app = module.createNestApplication();
    await app.init();
  });

  afterEach(async () => {
    await app.close();
  });

  describe('POST /v1/users', () => {
    it('ROOT 권한으로 유저를 생성한다', async () => {
      // Arrange
      MockJwtAuthGuard.mockUser = {
        sub: 'uuid-root',
        username: 'admin',
        role: 'ROOT',
      };
      mockUsersService.createUser.mockResolvedValue({
        id: 'uuid-2',
        username: 'newuser',
        role: 'USER',
      });
      // Act & Assert
      await request(app.getHttpServer())
        .post('/v1/users')
        .send({ username: 'newuser', password: 'password123' })
        .expect(201);
    });

    it('USER 권한으로 유저 생성 요청 시 403을 반환한다', async () => {
      // Arrange
      MockJwtAuthGuard.mockUser = {
        sub: 'uuid-1',
        username: 'user1',
        role: 'USER',
      };
      // Act & Assert
      await request(app.getHttpServer())
        .post('/v1/users')
        .send({ username: 'newuser', password: 'password123' })
        .expect(403);
    });
  });

  describe('GET /v1/users', () => {
    it('ROOT 권한으로 유저 목록을 반환한다', async () => {
      // Arrange
      MockJwtAuthGuard.mockUser = {
        sub: 'uuid-root',
        username: 'admin',
        role: 'ROOT',
      };
      mockUsersService.findAll.mockResolvedValue([
        { id: 'uuid-1', username: 'admin', role: 'ROOT' },
        { id: 'uuid-2', username: 'user1', role: 'USER' },
      ]);
      // Act & Assert
      await request(app.getHttpServer()).get('/v1/users').expect(200);
    });

    it('USER 권한으로 목록 조회 시 403을 반환한다', async () => {
      // Arrange
      MockJwtAuthGuard.mockUser = {
        sub: 'uuid-1',
        username: 'user1',
        role: 'USER',
      };
      // Act & Assert
      await request(app.getHttpServer()).get('/v1/users').expect(403);
    });
  });
});
