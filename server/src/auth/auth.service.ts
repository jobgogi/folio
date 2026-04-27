/**
 * @description JWT 기반 인증 비즈니스 로직
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AuthController
 */
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { LoginDto } from './dto/login.dto';

// Phase 1 임시 구현 — Phase 2에서 Prisma + DB 사용자 조회로 교체 예정
const MOCK_USER = { username: 'admin', password: 'password123' };

@Injectable()
export class AuthService {
  constructor(private readonly jwtService: JwtService) {}

  /**
   * @description 사용자 로그인 처리 및 JWT 액세스 토큰 발급
   * @param {LoginDto} dto 로그인 요청 DTO
   * @returns {Promise<{ accessToken: string }>} 액세스 토큰
   * @throws {UnauthorizedException} 자격증명이 올바르지 않을 시
   */
  async login(dto: LoginDto): Promise<{ accessToken: string }> {
    if (dto.username !== MOCK_USER.username || dto.password !== MOCK_USER.password) {
      throw new UnauthorizedException('자격증명이 올바르지 않습니다.');
    }
    const accessToken = this.jwtService.sign({ username: dto.username });
    return { accessToken };
  }
}
