/**
 * @description Auth 도메인 환경변수 설정 팩토리
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AuthModule
 */
import { registerAs } from '@nestjs/config';

export default registerAs('auth', () => ({
  jwtSecret: process.env.JWT_SECRET ?? 'dev-secret',
  jwtExpiresIn: process.env.JWT_EXPIRES_IN ?? '1h',
  nodeEnv: process.env.NODE_ENV ?? 'development',
}));
