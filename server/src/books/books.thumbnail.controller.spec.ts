/**
 * @description BooksController 썸네일 업로드 엔드포인트 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksController
 */
import { INestApplication, NotFoundException, BadRequestException } from '@nestjs/common';
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
};

describe('BooksController — uploadThumbnail', () => {
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

  describe('POST /v1/books/:id/thumbnail', () => {
    it('jpg 파일 업로드 시 201과 thumbnailPath를 반환한다', async () => {
      // Arrange
      mockBooksService.uploadThumbnail.mockResolvedValue({
        thumbnailPath: '/mnt/nas/.thumbnails/uuid-1.jpg',
      });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .post('/v1/books/uuid-1/thumbnail')
        .set('Authorization', `Bearer ${token}`)
        .attach('file', Buffer.from('imgdata'), 'cover.jpg')
        .expect(201)
        .expect((res) => {
          expect(res.body.thumbnailPath).toContain('uuid-1.jpg');
        });
    });

    it('png 파일 업로드 시 201과 thumbnailPath를 반환한다', async () => {
      // Arrange
      mockBooksService.uploadThumbnail.mockResolvedValue({
        thumbnailPath: '/mnt/nas/.thumbnails/uuid-1.png',
      });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .post('/v1/books/uuid-1/thumbnail')
        .set('Authorization', `Bearer ${token}`)
        .attach('file', Buffer.from('imgdata'), 'cover.png')
        .expect(201)
        .expect((res) => {
          expect(res.body.thumbnailPath).toContain('uuid-1.png');
        });
    });

    it('존재하지 않는 Book id이면 404를 반환한다', async () => {
      // Arrange
      mockBooksService.uploadThumbnail.mockRejectedValue(new NotFoundException());
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .post('/v1/books/not-exist/thumbnail')
        .set('Authorization', `Bearer ${token}`)
        .attach('file', Buffer.from('imgdata'), 'cover.jpg')
        .expect(404);
    });

    it('허용되지 않는 확장자이면 400을 반환한다', async () => {
      // Arrange
      mockBooksService.uploadThumbnail.mockRejectedValue(new BadRequestException());
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .post('/v1/books/uuid-1/thumbnail')
        .set('Authorization', `Bearer ${token}`)
        .attach('file', Buffer.from('imgdata'), 'cover.gif')
        .expect(400);
    });

    it('토큰 없으면 401을 반환한다', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .post('/v1/books/uuid-1/thumbnail')
        .attach('file', Buffer.from('imgdata'), 'cover.jpg')
        .expect(401);
    });
  });
});
