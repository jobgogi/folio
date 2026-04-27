/**
 * @description JWT 기반 인증 비즈니스 로직
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AuthController
 */
import { ForbiddenException, Inject, Injectable, UnauthorizedException } from '@nestjs/common';
import type { ConfigType } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import authConfig from '../config/auth.config';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { SetupDto } from './dto/setup.dto';

// Phase 1 임시 구현 — Phase 3 Task 3에서 bcrypt + DB 조회로 교체 예정
const MOCK_USER = { username: 'admin', password: 'password123' };

@Injectable()
export class AuthService {
  constructor(
    @Inject(authConfig.KEY)
    private readonly config: ConfigType<typeof authConfig>,
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
  ) {}

  /**
   * @description 셋업 필요 여부를 반환한다.
   * @returns {Promise<{ needsSetup: boolean }>} DB에 유저가 없으면 true
   */
  async getSetupStatus(): Promise<{ needsSetup: boolean }> {
    const count = await this.prisma.user.count();
    return { needsSetup: count === 0 };
  }

  /**
   * @description root 계정을 생성하고 JWT 토큰을 발급한다.
   * @param {SetupDto} dto 셋업 요청 DTO
   * @returns {Promise<{ accessToken: string; expiresIn: string }>} 액세스 토큰
   * @throws {ForbiddenException} 이미 유저가 존재할 시
   */
  async setup(dto: SetupDto): Promise<{ accessToken: string; expiresIn: string }> {
    const count = await this.prisma.user.count();
    if (count > 0) throw new ForbiddenException('이미 셋업이 완료되었습니다.');

    const hashed = await bcrypt.hash(dto.password, 10);
    await this.prisma.user.create({
      data: { username: dto.username, password: hashed, role: 'ROOT' },
    });

    const accessToken = this.jwtService.sign({ username: dto.username, role: 'ROOT' });
    return { accessToken, expiresIn: this.config.jwtExpiresIn };
  }

  /**
   * @description 사용자 로그인 처리 및 JWT 액세스 토큰 발급
   * @param {LoginDto} dto 로그인 요청 DTO
   * @returns {Promise<{ accessToken: string; expiresIn: string }>} 액세스 토큰과 만료 시간
   * @throws {UnauthorizedException} 자격증명이 올바르지 않을 시
   */
  async login(dto: LoginDto): Promise<{ accessToken: string; expiresIn: string }> {
    if (dto.username !== MOCK_USER.username || dto.password !== MOCK_USER.password) {
      throw new UnauthorizedException('자격증명이 올바르지 않습니다.');
    }
    const accessToken = this.jwtService.sign({ username: dto.username });
    return { accessToken, expiresIn: this.config.jwtExpiresIn };
  }
}
