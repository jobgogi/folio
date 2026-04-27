/**
 * @description NAS 도메인 환경변수 설정 팩토리
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BookSyncService
 */
import { registerAs } from '@nestjs/config';

export default registerAs('nas', () => ({
  mountPath: process.env.NAS_MOUNT_PATH,
}));
