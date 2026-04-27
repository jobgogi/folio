/**
 * @description JwtAuthGuard 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see JwtAuthGuard
 */
import { Test, TestingModule } from '@nestjs/testing';
import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import authConfig from '../config/auth.config';
import { JwtAuthGuard } from './jwt.guard';
import { JwtStrategy } from './jwt.strategy';

const TEST_SECRET = 'test-secret';

function mockContext(token?: string): ExecutionContext {
  return {
    switchToHttp: () => ({
      getRequest: () => ({
        headers: token ? { authorization: `Bearer ${token}` } : {},
      }),
      getResponse: () => ({}),
    }),
    getHandler: () => ({}),
    getClass: () => ({}),
  } as unknown as ExecutionContext;
}

describe('JwtAuthGuard', () => {
  let guard: JwtAuthGuard;
  let jwtService: JwtService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      imports: [
        PassportModule,
        JwtModule.register({ secret: TEST_SECRET, signOptions: { expiresIn: '1h' } }),
      ],
      providers: [
        JwtAuthGuard,
        JwtStrategy,
        { provide: authConfig.KEY, useValue: { jwtSecret: TEST_SECRET, jwtExpiresIn: '1h' } },
      ],
    }).compile();

    guard = module.get<JwtAuthGuard>(JwtAuthGuard);
    jwtService = module.get<JwtService>(JwtService);
  });

  it('유효한 토큰이면 true를 반환한다', async () => {
    // Arrange
    const token = jwtService.sign({ username: 'admin' });
    const ctx = mockContext(token);
    // Act
    const result = await guard.canActivate(ctx);
    // Assert
    expect(result).toBe(true);
  });

  it('토큰이 없으면 UnauthorizedException을 던진다', async () => {
    // Arrange
    const ctx = mockContext();
    // Act & Assert
    await expect(guard.canActivate(ctx)).rejects.toThrow(UnauthorizedException);
  });

  it('만료된 토큰이면 UnauthorizedException을 던진다', async () => {
    // Arrange
    const expired = jwtService.sign({ username: 'admin' }, { expiresIn: '-1s' });
    const ctx = mockContext(expired);
    // Act & Assert
    await expect(guard.canActivate(ctx)).rejects.toThrow(UnauthorizedException);
  });

  it('잘못된 서명의 토큰이면 UnauthorizedException을 던진다', async () => {
    // Arrange
    const invalid = 'invalid.token.value';
    const ctx = mockContext(invalid);
    // Act & Assert
    await expect(guard.canActivate(ctx)).rejects.toThrow(UnauthorizedException);
  });
});
