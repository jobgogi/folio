/**
 * @description 수동 싱크 트리거 API 컨트롤러
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see SyncModule
 */
import { Controller, Post } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { BookSyncService } from './book-sync.service';
import { SyncResult } from './book-sync.service';

@ApiTags('sync')
@Controller('v1/sync')
export class SyncController {
  constructor(private readonly bookSyncService: BookSyncService) {}

  /**
   * @description NAS 스캔 후 Book DB를 동기화한다.
   * @returns {Promise<SyncResult>} 추가/업데이트/삭제 카운트
   */
  @Post()
  @ApiOperation({ summary: '수동 싱크 트리거' })
  @ApiResponse({ status: 201, description: '싱크 완료' })
  sync(): Promise<SyncResult> {
    return this.bookSyncService.sync();
  }
}
