/**
 * @description AuthService.login() DB 기반 인증 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AuthService
 */
import { Test, TestingModule } from '@nestjs/testing';
import { UnauthorizedException } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import authConfig from '../config/auth.config';
import { PrismaService } from '../prisma/prisma.service';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';

const TEST_SECRET = 'test-secret';

const mockPrisma = {
  user: {
    count: jest.fn(),
    create: jest.fn(),
    findUnique: jest.fn(),
  },
};

describe('AuthService.login — DB 기반', () => {
  let service: AuthService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      imports: [
        JwtModule.register({ secret: TEST_SECRET, signOptions: { expiresIn: '1h' } }),
      ],
      providers: [
        AuthService,
        { provide: authConfig.KEY, useValue: { jwtSecret: TEST_SECRET, jwtExpiresIn: '1h' } },
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  it('올바른 자격증명이면 액세스 토큰과 expiresIn을 반환한다', async () => {
    // Arrange
    const hashed = await bcrypt.hash('securepass123', 10);
    mockPrisma.user.findUnique.mockResolvedValue({
      id: 'uuid-1', username: 'dbuser', password: hashed, role: 'USER',
    });
    const dto: LoginDto = { username: 'dbuser', password: 'securepass123' };
    // Act
    const result = await service.login(dto);
    // Assert
    expect(result).toHaveProperty('accessToken');
    expect(typeof result.accessToken).toBe('string');
    expect(result).toHaveProperty('expiresIn');
  });

  it('존재하지 않는 username이면 UnauthorizedException을 던진다', async () => {
    // Arrange
    mockPrisma.user.findUnique.mockResolvedValue(null);
    const dto: LoginDto = { username: 'nobody', password: 'securepass123' };
    // Act & Assert
    await expect(service.login(dto)).rejects.toThrow(UnauthorizedException);
  });

  it('password가 틀리면 UnauthorizedException을 던진다', async () => {
    // Arrange
    const hashed = await bcrypt.hash('correctpass123', 10);
    mockPrisma.user.findUnique.mockResolvedValue({
      id: 'uuid-1', username: 'dbuser', password: hashed, role: 'USER',
    });
    const dto: LoginDto = { username: 'dbuser', password: 'wrongpass123' };
    // Act & Assert
    await expect(service.login(dto)).rejects.toThrow(UnauthorizedException);
  });

  it('발급된 토큰의 payload에 username이 포함된다', async () => {
    // Arrange
    const hashed = await bcrypt.hash('securepass123', 10);
    mockPrisma.user.findUnique.mockResolvedValue({
      id: 'uuid-1', username: 'dbuser', password: hashed, role: 'USER',
    });
    const dto: LoginDto = { username: 'dbuser', password: 'securepass123' };
    // Act
    const result = await service.login(dto);
    const payload = JSON.parse(Buffer.from(result.accessToken.split('.')[1], 'base64').toString());
    // Assert
    expect(payload.username).toBe('dbuser');
  });

  it('발급된 토큰의 payload에 role이 포함된다', async () => {
    // Arrange
    const hashed = await bcrypt.hash('securepass123', 10);
    mockPrisma.user.findUnique.mockResolvedValue({
      id: 'uuid-1', username: 'dbuser', password: hashed, role: 'ROOT',
    });
    const dto: LoginDto = { username: 'dbuser', password: 'securepass123' };
    // Act
    const result = await service.login(dto);
    const payload = JSON.parse(Buffer.from(result.accessToken.split('.')[1], 'base64').toString());
    // Assert
    expect(payload.role).toBe('ROOT');
  });
});
