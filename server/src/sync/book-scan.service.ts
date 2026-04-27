/**
 * @description NAS 마운트 경로를 재귀 탐색하여 PDF/ePub 파일 목록 반환
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see SyncModule
 */
import { Injectable } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';

export interface ScannedFile {
  name: string;
  path: string;
  size: number;
  type: 'PDF' | 'EPUB';
}

const EXT_TYPE_MAP: Record<string, 'PDF' | 'EPUB'> = {
  '.pdf': 'PDF',
  '.epub': 'EPUB',
};

@Injectable()
export class BookScanService {
  /**
   * @description 지정 경로를 재귀 탐색하여 PDF/ePub 파일 목록을 반환한다.
   * @param {string} mountPath 탐색할 루트 경로
   * @returns {Promise<ScannedFile[]>} 스캔된 파일 목록
   */
  async scan(mountPath: string): Promise<ScannedFile[]> {
    return this.scanDir(mountPath);
  }

  private scanDir(dirPath: string): ScannedFile[] {
    const entries = fs.readdirSync(dirPath, { withFileTypes: true });
    const results: ScannedFile[] = [];

    for (const entry of entries) {
      const fullPath = path.join(dirPath, entry.name);

      if (entry.isDirectory()) {
        results.push(...this.scanDir(fullPath));
        continue;
      }

      const ext = path.extname(entry.name).toLowerCase();
      const type = EXT_TYPE_MAP[ext];
      if (!type) continue;

      const { size } = fs.statSync(fullPath);
      results.push({ name: entry.name, path: fullPath, size, type });
    }

    return results;
  }
}
