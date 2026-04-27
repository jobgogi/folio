/**
 * @description 애플리케이션 루트 모듈
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see FilesModule
 */
import { Module } from '@nestjs/common';
import { FilesModule } from './files/files.module';

@Module({
  imports: [FilesModule],
})
export class AppModule {}
