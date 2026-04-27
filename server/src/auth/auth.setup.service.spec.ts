/**
 * @description AuthService 셋업 기능 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AuthService
 */
import { Test, TestingModule } from '@nestjs/testing';
import { ForbiddenException } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import authConfig from '../config/auth.config';
import { PrismaService } from '../prisma/prisma.service';
import { AuthService } from './auth.service';
import { SetupDto } from './dto/setup.dto';

const TEST_SECRET = 'test-secret';

const mockPrisma = {
  user: {
    count: jest.fn(),
    create: jest.fn(),
  },
};

describe('AuthService - setup', () => {
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

  describe('getSetupStatus', () => {
    it('유저가 없으면 needsSetup: true를 반환한다', async () => {
      mockPrisma.user.count.mockResolvedValue(0);
      const result = await service.getSetupStatus();
      expect(result).toEqual({ needsSetup: true });
    });

    it('유저가 있으면 needsSetup: false를 반환한다', async () => {
      mockPrisma.user.count.mockResolvedValue(1);
      const result = await service.getSetupStatus();
      expect(result).toEqual({ needsSetup: false });
    });
  });

  describe('setup', () => {
    it('root 계정을 생성하고 액세스 토큰과 expiresIn을 반환한다', async () => {
      mockPrisma.user.count.mockResolvedValue(0);
      mockPrisma.user.create.mockResolvedValue({ username: 'admin' });
      const dto: SetupDto = { username: 'admin', password: 'password123' };
      const result = await service.setup(dto);
      expect(result).toHaveProperty('accessToken');
      expect(typeof result.accessToken).toBe('string');
      expect(result).toHaveProperty('expiresIn');
    });

    it('이미 유저가 있으면 ForbiddenException을 던진다', async () => {
      mockPrisma.user.count.mockResolvedValue(1);
      const dto: SetupDto = { username: 'admin', password: 'password123' };
      await expect(service.setup(dto)).rejects.toThrow(ForbiddenException);
    });

    it('저장되는 password는 bcrypt로 해싱되어 원문과 다르다', async () => {
      mockPrisma.user.count.mockResolvedValue(0);
      mockPrisma.user.create.mockResolvedValue({ username: 'admin' });
      const dto: SetupDto = { username: 'admin', password: 'password123' };
      await service.setup(dto);
      const savedPassword = mockPrisma.user.create.mock.calls[0][0].data.password;
      expect(savedPassword).not.toBe('password123');
    });
  });
});
