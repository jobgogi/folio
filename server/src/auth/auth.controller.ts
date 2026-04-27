/**
 * @description JWT 로그인 및 셋업 REST API 컨트롤러
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AuthService
 */
import {
  Body,
  Controller,
  Get,
  Post,
  Req,
  Res,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import type { Request, Response } from 'express';
import { JwtAuthGuard } from './jwt.guard';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { SetupDto } from './dto/setup.dto';

const COOKIE_NAME = 'access_token';

@ApiTags('auth')
@Controller('v1/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * @description 셋업 필요 여부를 반환한다.
   * @returns {Promise<{ needsSetup: boolean }>}
   */
  @Get('setup-status')
  @ApiOperation({ summary: '셋업 필요 여부 조회' })
  @ApiResponse({ status: 200, description: '셋업 상태 반환' })
  getSetupStatus(): Promise<{ needsSetup: boolean }> {
    return this.authService.getSetupStatus();
  }

  /**
   * @description root 계정을 생성하고 httpOnly 쿠키로 토큰을 발급한다.
   * @param {SetupDto} dto 셋업 요청 DTO
   * @param {Response} res HTTP 응답 객체
   * @returns {{ message: string }}
   */
  @Post('setup')
  @ApiOperation({ summary: 'root 계정 생성 (최초 1회)' })
  @ApiResponse({ status: 201, description: '쿠키 발급 성공' })
  @ApiResponse({ status: 400, description: 'DTO 유효성 검사 실패' })
  @ApiResponse({ status: 403, description: '이미 셋업 완료' })
  async setup(
    @Body() dto: SetupDto,
    @Res({ passthrough: true }) res: Response,
  ): Promise<{ message: string }> {
    const token = await this.authService.setup(dto);
    res.cookie(COOKIE_NAME, token, this.authService.getCookieOptions());
    return { message: 'ok' };
  }

  /**
   * @description 로그인 후 httpOnly 쿠키로 토큰을 발급한다.
   * @param {LoginDto} dto 로그인 요청 DTO
   * @param {Response} res HTTP 응답 객체
   * @returns {{ message: string }}
   */
  @Post('login')
  @ApiOperation({ summary: '로그인' })
  @ApiResponse({ status: 201, description: '쿠키 발급 성공' })
  @ApiResponse({ status: 401, description: '자격증명 불일치' })
  async login(
    @Body() dto: LoginDto,
    @Res({ passthrough: true }) res: Response,
  ): Promise<{ message: string }> {
    const token = await this.authService.login(dto);
    res.cookie(COOKIE_NAME, token, this.authService.getCookieOptions());
    return { message: 'ok' };
  }

  /**
   * @description 로그아웃 — httpOnly 쿠키를 삭제한다.
   * @param {Response} res HTTP 응답 객체
   * @returns {{ message: string }}
   */
  @Post('logout')
  @ApiOperation({ summary: '로그아웃' })
  @ApiResponse({ status: 201, description: '로그아웃 성공' })
  logout(@Res({ passthrough: true }) res: Response): { message: string } {
    res.cookie(COOKIE_NAME, '', {
      ...this.authService.getCookieOptions(),
      maxAge: 0,
    });
    return { message: 'ok' };
  }

  /**
   * @description 현재 로그인한 유저 정보를 반환한다.
   * @param {Request} req HTTP 요청 객체 (JWT payload 포함)
   * @returns {Promise<{ id: string; username: string; role: string; avatar: string | null }>}
   */
  @Get('me')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '현재 유저 정보 조회' })
  @ApiResponse({ status: 200, description: '유저 정보 반환' })
  @ApiResponse({ status: 401, description: '인증 필요' })
  getMe(@Req() req: Request) {
    const { sub } = req.user as { sub: string };
    return this.authService.getMe(sub);
  }
}
