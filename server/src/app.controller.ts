/**
 * @description 앱 공통 엔드포인트 컨트롤러 (헬스체크)
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AppModule
 */
import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';

@ApiTags('health')
@Controller('v1')
export class AppController {
  /**
   * @description 서버 상태를 반환한다.
   * @returns {{ status: string }} 서버 상태
   */
  @Get('health')
  @ApiOperation({ summary: '헬스체크' })
  @ApiOkResponse({ description: '서버 정상' })
  health(): { status: string } {
    return { status: 'ok' };
  }
}
