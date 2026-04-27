/**
 * @description AuthService 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AuthService
 */
import { Test, TestingModule } from '@nestjs/testing';
import { UnauthorizedException } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';

describe('AuthService', () => {
  let service: AuthService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [JwtModule.register({ secret: 'test-secret', signOptions: { expiresIn: '1h' } })],
      providers: [AuthService],
    }).compile();

    service = module.get<AuthService>(AuthService);
  });

  describe('login', () => {
    it('올바른 자격증명이면 액세스 토큰을 반환한다', async () => {
      // Arrange
      const dto: LoginDto = { username: 'admin', password: 'password123' };
      // Act
      const result = await service.login(dto);
      // Assert
      expect(result).toHaveProperty('accessToken');
      expect(typeof result.accessToken).toBe('string');
      expect(result.accessToken.length).toBeGreaterThan(0);
    });

    it('잘못된 username이면 UnauthorizedException을 던진다', async () => {
      const dto: LoginDto = { username: 'wrong', password: 'password123' };
      await expect(service.login(dto)).rejects.toThrow(UnauthorizedException);
    });

    it('잘못된 password이면 UnauthorizedException을 던진다', async () => {
      const dto: LoginDto = { username: 'admin', password: 'wrong' };
      await expect(service.login(dto)).rejects.toThrow(UnauthorizedException);
    });

    it('반환된 토큰은 JWT 형식이다 (header.payload.signature)', async () => {
      const dto: LoginDto = { username: 'admin', password: 'password123' };
      const result = await service.login(dto);
      const parts = result.accessToken.split('.');
      expect(parts).toHaveLength(3);
    });
  });
});
