/**
 * @description BookScanService 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BookScanService
 */
import { Test, TestingModule } from '@nestjs/testing';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';
import { BookScanService } from './book-scan.service';

describe('BookScanService', () => {
  let service: BookScanService;
  let tmpDir: string;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [BookScanService],
    }).compile();

    service = module.get<BookScanService>(BookScanService);
    tmpDir = fs.mkdtempSync(path.join(os.tmpdir(), 'book-scan-'));
  });

  afterEach(() => {
    fs.rmSync(tmpDir, { recursive: true });
  });

  describe('scan', () => {
    it('PDF 파일을 감지해 반환한다', async () => {
      // Arrange
      fs.writeFileSync(path.join(tmpDir, 'book.pdf'), '');
      // Act
      const result = await service.scan(tmpDir);
      // Assert
      expect(result).toEqual([
        {
          name: 'book.pdf',
          path: path.join(tmpDir, 'book.pdf'),
          size: 0,
          type: 'PDF',
        },
      ]);
    });

    it('ePub 파일을 감지해 반환한다', async () => {
      // Arrange
      fs.writeFileSync(path.join(tmpDir, 'novel.epub'), '');
      // Act
      const result = await service.scan(tmpDir);
      // Assert
      expect(result).toEqual([
        {
          name: 'novel.epub',
          path: path.join(tmpDir, 'novel.epub'),
          size: 0,
          type: 'EPUB',
        },
      ]);
    });

    it('PDF / ePub 외 파일은 필터링한다', async () => {
      // Arrange
      fs.writeFileSync(path.join(tmpDir, 'readme.txt'), '');
      fs.writeFileSync(path.join(tmpDir, 'image.png'), '');
      // Act
      const result = await service.scan(tmpDir);
      // Assert
      expect(result).toEqual([]);
    });

    it('빈 디렉토리이면 빈 배열을 반환한다', async () => {
      // Act
      const result = await service.scan(tmpDir);
      // Assert
      expect(result).toEqual([]);
    });

    it('중첩 디렉토리를 재귀 탐색한다', async () => {
      // Arrange
      const subDir = path.join(tmpDir, 'sub');
      fs.mkdirSync(subDir);
      fs.writeFileSync(path.join(subDir, 'deep.pdf'), '');
      // Act
      const result = await service.scan(tmpDir);
      // Assert
      expect(result).toEqual([
        {
          name: 'deep.pdf',
          path: path.join(subDir, 'deep.pdf'),
          size: 0,
          type: 'PDF',
        },
      ]);
    });
  });
});
