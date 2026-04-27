/**
 * @description 앱 공통 환경변수 설정 팩토리
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AppModule
 */
import { registerAs } from '@nestjs/config';

export default registerAs('app', () => ({
  corsOrigin: process.env.CORS_ORIGIN ?? 'http://localhost',
}));
