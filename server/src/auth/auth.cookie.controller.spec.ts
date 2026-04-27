/**
 * @description AuthController httpOnly 쿠키 동작 통합 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AuthController
 */
import { INestApplication, UnauthorizedException } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import cookieParser from 'cookie-parser';
import request from 'supertest';
import authConfig from '../config/auth.config';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './jwt.guard';
import { JwtStrategy } from './jwt.strategy';

const TEST_SECRET = 'test-secret';

const mockAuthService = {
  getSetupStatus: jest.fn(),
  setup: jest.fn(),
  login: jest.fn(),
  getMe: jest.fn(),
  getCookieOptions: jest
    .fn()
    .mockReturnValue({ httpOnly: true, sameSite: 'lax', secure: false, maxAge: 3600 * 1000 }),
};

describe('AuthController — httpOnly 쿠키', () => {
  let app: INestApplication;
  let jwtService: JwtService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      imports: [
        PassportModule.register({ defaultStrategy: 'jwt' }),
        JwtModule.register({ secret: TEST_SECRET }),
      ],
      controllers: [AuthController],
      providers: [
        { provide: AuthService, useValue: mockAuthService },
        {
          provide: authConfig.KEY,
          useValue: { jwtSecret: TEST_SECRET, jwtExpiresIn: '1h' },
        },
        JwtStrategy,
        JwtAuthGuard,
      ],
    }).compile();

    app = module.createNestApplication();
    app.use(cookieParser());
    await app.init();
    jwtService = module.get<JwtService>(JwtService);
  });

  afterEach(() => app.close());

  describe('POST /v1/auth/login', () => {
    it('성공 시 httpOnly 쿠키를 설정하고 { message: ok }를 반환한다', async () => {
      // Arrange
      const token = jwtService.sign({
        sub: 'uuid-1',
        username: 'admin',
        role: 'ROOT',
      });
      mockAuthService.login.mockResolvedValue(token);
      // Act
      const res = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({ username: 'admin', password: 'password123' })
        .expect(201);
      // Assert
      const cookies = res.headers['set-cookie'] as string[];
      const accessCookie = cookies?.find((c) => c.startsWith('access_token='));
      expect(accessCookie).toBeDefined();
      expect(accessCookie).toContain('HttpOnly');
      expect(res.body).toEqual({ message: 'ok' });
    });

    it('실패 시 쿠키를 설정하지 않는다', async () => {
      // Arrange
      mockAuthService.login.mockRejectedValue(new UnauthorizedException());
      // Act
      const res = await request(app.getHttpServer())
        .post('/v1/auth/login')
        .send({ username: 'wrong', password: 'wrong' })
        .expect(401);
      // Assert
      expect(res.headers['set-cookie']).toBeUndefined();
    });
  });

  describe('POST /v1/auth/logout', () => {
    it('쿠키를 삭제한다 (Max-Age=0)', async () => {
      // Arrange
      const token = jwtService.sign({
        sub: 'uuid-1',
        username: 'admin',
        role: 'ROOT',
      });
      // Act
      const res = await request(app.getHttpServer())
        .post('/v1/auth/logout')
        .set('Cookie', `access_token=${token}`)
        .expect(201);
      // Assert
      const cookies = res.headers['set-cookie'] as string[];
      const accessCookie = cookies?.find((c) => c.startsWith('access_token='));
      expect(accessCookie).toBeDefined();
      expect(accessCookie).toContain('Max-Age=0');
    });
  });

  describe('GET /v1/auth/me', () => {
    it('유효한 쿠키가 있으면 유저 정보를 반환한다', async () => {
      // Arrange
      const token = jwtService.sign({
        sub: 'uuid-1',
        username: 'admin',
        role: 'ROOT',
      });
      mockAuthService.getMe.mockResolvedValue({
        id: 'uuid-1',
        username: 'admin',
        role: 'ROOT',
        avatar: null,
      });
      // Act
      const res = await request(app.getHttpServer())
        .get('/v1/auth/me')
        .set('Cookie', `access_token=${token}`)
        .expect(200);
      // Assert
      expect(res.body).toMatchObject({
        id: 'uuid-1',
        username: 'admin',
        role: 'ROOT',
        avatar: null,
      });
    });

    it('쿠키가 없으면 401을 반환한다', async () => {
      // Act & Assert
      await request(app.getHttpServer()).get('/v1/auth/me').expect(401);
    });
  });

  describe('POST /v1/auth/setup', () => {
    it('성공 시 httpOnly 쿠키를 설정하고 { message: ok }를 반환한다', async () => {
      // Arrange
      const token = jwtService.sign({
        sub: 'uuid-root',
        username: 'admin',
        role: 'ROOT',
      });
      mockAuthService.setup.mockResolvedValue(token);
      // Act
      const res = await request(app.getHttpServer())
        .post('/v1/auth/setup')
        .send({ username: 'admin', password: 'password123' })
        .expect(201);
      // Assert
      const cookies = res.headers['set-cookie'] as string[];
      const accessCookie = cookies?.find((c) => c.startsWith('access_token='));
      expect(accessCookie).toBeDefined();
      expect(accessCookie).toContain('HttpOnly');
      expect(res.body).toEqual({ message: 'ok' });
    });
  });
});
