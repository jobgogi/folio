/**
 * @description BooksController JWT 가드 적용 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksController
 */
import { INestApplication } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import request from 'supertest';
import authConfig from '../config/auth.config';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { JwtStrategy } from '../auth/jwt.strategy';
import { BooksController } from './books.controller';
import { BooksService } from './books.service';

const TEST_SECRET = 'test-secret';
const mockBooksService = {
  findAll: jest.fn(),
  findOne: jest.fn(),
  update: jest.fn(),
  open: jest.fn(),
};

describe('BooksController — JWT 가드', () => {
  let app: INestApplication;
  let jwtService: JwtService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      imports: [
        PassportModule.register({ defaultStrategy: 'jwt' }),
        JwtModule.register({ secret: TEST_SECRET }),
      ],
      controllers: [BooksController],
      providers: [
        { provide: BooksService, useValue: mockBooksService },
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

  describe('GET /v1/books', () => {
    it('토큰 없으면 401을 반환한다', () => {
      return request(app.getHttpServer())
        .get('/v1/books')
        .expect(401);
    });

    it('유효한 토큰이면 정상 응답한다', async () => {
      // Arrange
      mockBooksService.findAll.mockResolvedValue({ data: [], meta: { total: 0, page: 1, limit: 20, totalPages: 0 } });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      return request(app.getHttpServer())
        .get('/v1/books')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);
    });
  });

  describe('GET /v1/books/:id', () => {
    it('토큰 없으면 401을 반환한다', () => {
      return request(app.getHttpServer())
        .get('/v1/books/uuid-1')
        .expect(401);
    });

    it('유효한 토큰이면 정상 응답한다', async () => {
      // Arrange
      mockBooksService.findOne.mockResolvedValue({ id: 'uuid-1', title: 'Clean Code' });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      return request(app.getHttpServer())
        .get('/v1/books/uuid-1')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);
    });
  });

  describe('PATCH /v1/books/:id', () => {
    it('토큰 없으면 401을 반환한다', () => {
      return request(app.getHttpServer())
        .patch('/v1/books/uuid-1')
        .send({ title: 'New Title' })
        .expect(401);
    });

    it('유효한 토큰이면 정상 응답한다', async () => {
      // Arrange
      mockBooksService.update.mockResolvedValue({ id: 'uuid-1', title: 'New Title' });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      return request(app.getHttpServer())
        .patch('/v1/books/uuid-1')
        .set('Authorization', `Bearer ${token}`)
        .send({ title: 'New Title' })
        .expect(200);
    });
  });

  describe('PATCH /v1/books/:id/open', () => {
    it('토큰 없으면 401을 반환한다', () => {
      return request(app.getHttpServer())
        .patch('/v1/books/uuid-1/open')
        .expect(401);
    });

    it('유효한 토큰이면 정상 응답한다', async () => {
      // Arrange
      mockBooksService.open.mockResolvedValue({ id: 'uuid-1', lastOpenedAt: new Date() });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      return request(app.getHttpServer())
        .patch('/v1/books/uuid-1/open')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);
    });
  });
});
