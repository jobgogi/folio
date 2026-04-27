/**
 * @description BooksController 썸네일 다운로드 엔드포인트 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksController
 */
import { INestApplication, NotFoundException } from '@nestjs/common';
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
  download: jest.fn(),
  uploadThumbnail: jest.fn(),
  downloadThumbnail: jest.fn(),
};

describe('BooksController — downloadThumbnail', () => {
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
        {
          provide: authConfig.KEY,
          useValue: { jwtSecret: TEST_SECRET, jwtExpiresIn: '1h' },
        },
        JwtStrategy,
        JwtAuthGuard,
      ],
    }).compile();

    app = module.createNestApplication();
    await app.init();
    jwtService = module.get<JwtService>(JwtService);
  });

  afterEach(() => app.close());

  describe('GET /v1/books/:id/thumbnail', () => {
    it('썸네일을 다운로드하고 200을 반환한다', async () => {
      // Arrange
      mockBooksService.downloadThumbnail.mockResolvedValue({
        buffer: Buffer.from('imgdata'),
        ext: 'jpg',
      });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .get('/v1/books/uuid-1/thumbnail')
        .set('Authorization', `Bearer ${token}`)
        .expect(200);
    });

    it('Content-Type이 image/jpeg이다', async () => {
      // Arrange
      mockBooksService.downloadThumbnail.mockResolvedValue({
        buffer: Buffer.from('imgdata'),
        ext: 'jpg',
      });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .get('/v1/books/uuid-1/thumbnail')
        .set('Authorization', `Bearer ${token}`)
        .expect(200)
        .expect('Content-Type', /image\/jpeg/);
    });

    it('Content-Disposition: attachment 헤더가 설정된다', async () => {
      // Arrange
      mockBooksService.downloadThumbnail.mockResolvedValue({
        buffer: Buffer.from('imgdata'),
        ext: 'jpg',
      });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .get('/v1/books/uuid-1/thumbnail')
        .set('Authorization', `Bearer ${token}`)
        .expect(200)
        .expect('Content-Disposition', /attachment/);
    });

    it('썸네일이 없으면 404를 반환한다', async () => {
      // Arrange
      mockBooksService.downloadThumbnail.mockRejectedValue(
        new NotFoundException(),
      );
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .get('/v1/books/uuid-1/thumbnail')
        .set('Authorization', `Bearer ${token}`)
        .expect(404);
    });

    it('존재하지 않는 id이면 404를 반환한다', async () => {
      // Arrange
      mockBooksService.downloadThumbnail.mockRejectedValue(
        new NotFoundException(),
      );
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .get('/v1/books/not-exist/thumbnail')
        .set('Authorization', `Bearer ${token}`)
        .expect(404);
    });

    it('토큰 없으면 401을 반환한다', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .get('/v1/books/uuid-1/thumbnail')
        .expect(401);
    });
  });
});
