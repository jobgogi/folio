/**
 * @description 파일 목록 및 단일 파일 조회 REST API 컨트롤러
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see FilesService
 */
import { Controller, Get, Param } from '@nestjs/common';
import {
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { FilesService } from './files.service';
import { FileDto } from './dto/file.dto';

@ApiTags('files')
@Controller('v1/files')
export class FilesController {
  constructor(private readonly filesService: FilesService) {}

  /**
   * @description 전체 파일 목록을 반환한다.
   * @returns {Promise<FileDto[]>} 파일 목록
   */
  @Get()
  @ApiOperation({ summary: '파일 목록 조회' })
  @ApiOkResponse({ type: [FileDto], description: '파일 목록 반환' })
  findAll(): Promise<FileDto[]> {
    return this.filesService.findAll();
  }

  /**
   * @description id로 단일 파일을 조회한다.
   * @param {string} id 파일 고유 식별자
   * @returns {Promise<FileDto>} 파일 정보
   * @throws {NotFoundException} 파일 없음 (404)
   */
  @Get(':id')
  @ApiOperation({ summary: '단일 파일 조회' })
  @ApiOkResponse({ type: FileDto, description: '단일 파일 반환' })
  @ApiNotFoundResponse({ description: '파일 없음' })
  findOne(@Param('id') id: string): Promise<FileDto> {
    return this.filesService.findOne(id);
  }
}
