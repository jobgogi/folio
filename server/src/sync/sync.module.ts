/**
 * @description 싱크 도메인 모듈
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AppModule
 */
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import nasConfig from '../config/nas.config';
import { AuthModule } from '../auth/auth.module';
import { PrismaModule } from '../prisma/prisma.module';
import { BookScanService } from './book-scan.service';
import { BookMetaExtractService } from './book-meta-extract.service';
import { BookSyncService } from './book-sync.service';
import { SyncController } from './sync.controller';

@Module({
  imports: [ConfigModule.forFeature(nasConfig), PrismaModule, AuthModule],
  controllers: [SyncController],
  providers: [BookScanService, BookMetaExtractService, BookSyncService],
})
export class SyncModule {}
