/**
 * @description 인증 기능을 제공하는 NestJS 모듈
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AuthController, AuthService
 */
import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { JwtModule } from '@nestjs/jwt';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Module({
  imports: [
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const secret = config.get<string>('JWT_SECRET');
        if (!secret && config.get('NODE_ENV') === 'production') {
          throw new Error('JWT_SECRET 환경변수가 설정되지 않았습니다.');
        }
        return {
          secret: secret ?? 'dev-secret',
          signOptions: { expiresIn: config.get<string>('JWT_EXPIRES_IN') ?? '1h' },
        };
      },
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService],
})
export class AuthModule {}
