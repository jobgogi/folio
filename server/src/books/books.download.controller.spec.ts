/**
 * @description BooksController 다운로드 엔드포인트 테스트
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
};

describe('BooksController — download', () => {
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

  describe('GET /v1/books/:id/download', () => {
    it('PDF 파일을 다운로드하고 Content-Type이 application/pdf이다', async () => {
      // Arrange
      mockBooksService.download.mockResolvedValue({
        buffer: Buffer.from('pdf-data'),
        contentType: 'application/pdf',
        filename: 'clean_code.pdf',
      });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .get('/v1/books/uuid-1/download')
        .set('Authorization', `Bearer ${token}`)
        .expect(200)
        .expect('Content-Type', /application\/pdf/);
    });

    it('ePub 파일을 다운로드하고 Content-Type이 application/epub+zip이다', async () => {
      // Arrange
      mockBooksService.download.mockResolvedValue({
        buffer: Buffer.from('epub-data'),
        contentType: 'application/epub+zip',
        filename: 'dune.epub',
      });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .get('/v1/books/uuid-1/download')
        .set('Authorization', `Bearer ${token}`)
        .expect(200)
        .expect('Content-Type', /application\/epub\+zip/);
    });

    it('Content-Disposition: attachment 헤더가 설정된다', async () => {
      // Arrange
      mockBooksService.download.mockResolvedValue({
        buffer: Buffer.from('pdf-data'),
        contentType: 'application/pdf',
        filename: 'clean_code.pdf',
      });
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .get('/v1/books/uuid-1/download')
        .set('Authorization', `Bearer ${token}`)
        .expect(200)
        .expect('Content-Disposition', /attachment/);
    });

    it('존재하지 않는 id이면 404를 반환한다', async () => {
      // Arrange
      mockBooksService.download.mockRejectedValue(new NotFoundException());
      const token = jwtService.sign({ username: 'admin', role: 'ROOT' });
      // Act & Assert
      await request(app.getHttpServer())
        .get('/v1/books/not-exist/download')
        .set('Authorization', `Bearer ${token}`)
        .expect(404);
    });

    it('토큰 없으면 401을 반환한다', async () => {
      // Act & Assert
      await request(app.getHttpServer())
        .get('/v1/books/uuid-1/download')
        .expect(401);
    });
  });
});
