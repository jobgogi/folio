/**
 * @description JWT 로그인 및 셋업 REST API 컨트롤러
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AuthService
 */
import { Body, Controller, Get, Post } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { SetupDto } from './dto/setup.dto';

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
   * @description root 계정을 생성하고 JWT 토큰을 발급한다.
   * @param {SetupDto} dto 셋업 요청 DTO
   * @returns {Promise<{ accessToken: string; expiresIn: string }>}
   */
  @Post('setup')
  @ApiOperation({ summary: 'root 계정 생성 (최초 1회)' })
  @ApiResponse({ status: 201, description: '토큰 발급 성공' })
  @ApiResponse({ status: 400, description: 'DTO 유효성 검사 실패' })
  @ApiResponse({ status: 403, description: '이미 셋업 완료' })
  setup(@Body() dto: SetupDto): Promise<{ accessToken: string; expiresIn: string }> {
    return this.authService.setup(dto);
  }

  /**
   * @description 사용자 로그인 후 JWT 액세스 토큰을 발급한다.
   * @param {LoginDto} loginDto 로그인 요청 DTO
   * @returns {Promise<{ accessToken: string; expiresIn: string }>} 액세스 토큰
   */
  @Post('login')
  @ApiOperation({ summary: '로그인' })
  @ApiResponse({ status: 201, description: '토큰 발급 성공' })
  @ApiResponse({ status: 401, description: '자격증명 불일치' })
  login(@Body() loginDto: LoginDto): Promise<{ accessToken: string; expiresIn: string }> {
    return this.authService.login(loginDto);
  }
}
