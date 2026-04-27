/**
 * @description 스캔 결과를 DB와 비교하여 Book 추가/업데이트/삭제 처리
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see SyncModule
 */
import { Inject, Injectable } from '@nestjs/common';
import type { ConfigType } from '@nestjs/config';
import nasConfig from '../config/nas.config';
import { BookScanService } from './book-scan.service';
import { BookMetaExtractService } from './book-meta-extract.service';
import { PrismaService } from '../prisma/prisma.service';

export interface SyncResult {
  added: number;
  updated: number;
  deleted: number;
}

@Injectable()
export class BookSyncService {
  constructor(
    @Inject(nasConfig.KEY)
    private readonly nas: ConfigType<typeof nasConfig>,
    private readonly scanService: BookScanService,
    private readonly metaService: BookMetaExtractService,
    private readonly prisma: PrismaService,
  ) {}

  /**
   * @description NAS를 스캔하고 DB와 비교하여 Book을 동기화한다.
   * @returns {Promise<SyncResult>} 추가/업데이트/삭제 카운트
   */
  async sync(): Promise<SyncResult> {
    const mountPath = this.nas.mountPath ?? '';

    const [rawScanned, dbBooks] = await Promise.all([
      this.scanService.scan(mountPath),
      this.prisma.book.findMany(),
    ]);

    // 동일 경로 중복 제거 (macOS case-insensitive FS 등에서 발생 가능)
    const scanned = [...new Map(rawScanned.map((f) => [f.path, f])).values()];

    const dbByPath = new Map(dbBooks.map((b) => [b.path, b]));
    const scannedPaths = new Set(scanned.map((f) => f.path));

    let added = 0;
    let updated = 0;

    for (const file of scanned) {
      const existing = dbByPath.get(file.path);
      if (existing) {
        await this.prisma.book.update({
          where: { id: existing.id },
          data: { lastSyncAt: new Date() },
        });
        updated++;
      } else {
        const meta = await this.metaService.extract(
          file.path,
          file.type,
          file.name,
        );
        await this.prisma.book.upsert({
          where: { path: file.path },
          update: { lastSyncAt: new Date() },
          create: {
            name: file.name,
            type: file.type,
            path: file.path,
            size: file.size,
            lastSyncAt: new Date(),
            ...meta,
          },
        });
        added++;
      }
    }

    const toDelete = dbBooks.filter((b) => !scannedPaths.has(b.path));
    let deleted = 0;

    if (toDelete.length > 0) {
      await this.prisma.book.deleteMany({
        where: { id: { in: toDelete.map((b) => b.id) } },
      });
      deleted = toDelete.length;
    }

    return { added, updated, deleted };
  }
}
