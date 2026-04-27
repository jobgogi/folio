/**
 * @description 인증 기능을 제공하는 NestJS 모듈
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AuthController, AuthService
 */
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Module({
  imports: [
    JwtModule.register({
      secret:
        process.env.JWT_SECRET ??
        (process.env.NODE_ENV === 'production'
          ? (() => { throw new Error('JWT_SECRET 환경변수가 설정되지 않았습니다.'); })()
          : 'dev-secret'),
      signOptions: { expiresIn: process.env.JWT_EXPIRES_IN ?? '1h' },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService],
})
export class AuthModule {}
