/**
 * @description Book 조회 및 수정 API 컨트롤러
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksModule
 */
import {
  Body,
  Controller,
  Get,
  Param,
  ParseFilePipe,
  Patch,
  Post,
  Query,
  Res,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import {
  ApiBearerAuth,
  ApiConsumes,
  ApiOperation,
  ApiResponse,
  ApiTags,
} from '@nestjs/swagger';
import type { Response } from 'express';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { BooksService } from './books.service';
import { GetBooksQueryDto } from './dto/get-books-query.dto';
import { UpdateBookDto } from './dto/update-book.dto';

@ApiTags('books')
@ApiBearerAuth()
@Controller('v1/books')
@UseGuards(JwtAuthGuard)
export class BooksController {
  constructor(private readonly booksService: BooksService) {}

  /**
   * @description Book 목록을 페이징 및 정렬하여 반환한다.
   * @param {GetBooksQueryDto} query 페이징/정렬 쿼리
   * @returns 페이징된 Book 목록과 메타 정보
   */
  @Get()
  @ApiOperation({ summary: 'Book 목록 조회 (페이징/정렬)' })
  @ApiResponse({ status: 200, description: 'Book 목록 반환' })
  @ApiResponse({ status: 400, description: '잘못된 쿼리 파라미터' })
  @ApiResponse({ status: 401, description: '인증 필요' })
  findAll(@Query() query: GetBooksQueryDto) {
    return this.booksService.findAll(query);
  }

  /**
   * @description 단일 Book을 반환한다.
   * @param {string} id Book ID
   * @returns Book
   */
  @Get(':id')
  @ApiOperation({ summary: '단일 Book 조회' })
  @ApiResponse({ status: 200, description: 'Book 반환' })
  @ApiResponse({ status: 401, description: '인증 필요' })
  @ApiResponse({ status: 404, description: 'Book 없음' })
  findOne(@Param('id') id: string) {
    return this.booksService.findOne(id);
  }

  /**
   * @description Book 메타데이터를 수정한다.
   * @param {string} id Book ID
   * @param {UpdateBookDto} dto 수정할 필드
   * @returns 수정된 Book
   */
  @Patch(':id')
  @ApiOperation({ summary: 'Book 메타데이터 수정' })
  @ApiResponse({ status: 200, description: '수정된 Book 반환' })
  @ApiResponse({ status: 401, description: '인증 필요' })
  @ApiResponse({ status: 404, description: 'Book 없음' })
  update(@Param('id') id: string, @Body() dto: UpdateBookDto) {
    return this.booksService.update(id, dto);
  }

  /**
   * @description 마지막 열람 시각을 현재 시각으로 갱신한다.
   * @param {string} id Book ID
   * @returns 갱신된 Book
   */
  @Patch(':id/open')
  @ApiOperation({ summary: '마지막 열람 시각 갱신' })
  @ApiResponse({ status: 200, description: 'lastOpenedAt 갱신된 Book 반환' })
  @ApiResponse({ status: 401, description: '인증 필요' })
  @ApiResponse({ status: 404, description: 'Book 없음' })
  open(@Param('id') id: string) {
    return this.booksService.open(id);
  }

  /**
   * @description 썸네일 이미지를 업로드한다.
   * @param {string} id Book ID
   * @param {Express.Multer.File} file 업로드 파일
   * @returns {{ thumbnailPath: string }} 저장된 썸네일 경로
   */
  @Post(':id/thumbnail')
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: '썸네일 업로드' })
  @ApiResponse({ status: 201, description: '업로드 성공' })
  @ApiResponse({
    status: 400,
    description: '파일 없음, 허용되지 않는 확장자 또는 5MB 초과',
  })
  @ApiResponse({ status: 401, description: '인증 필요' })
  @ApiResponse({ status: 404, description: 'Book 없음' })
  uploadThumbnail(
    @Param('id') id: string,
    @UploadedFile(new ParseFilePipe({ fileIsRequired: true }))
    file: Express.Multer.File,
  ) {
    return this.booksService.uploadThumbnail(id, file);
  }

  /**
   * @description 썸네일 이미지를 다운로드한다.
   * @param {string} id Book ID
   * @param {Response} res HTTP 응답 객체
   */
  @Get(':id/thumbnail')
  @ApiOperation({ summary: '썸네일 다운로드' })
  @ApiResponse({ status: 200, description: '다운로드 성공' })
  @ApiResponse({ status: 401, description: '인증 필요' })
  @ApiResponse({ status: 404, description: 'Book 없음 또는 썸네일 없음' })
  async downloadThumbnail(@Param('id') id: string, @Res() res: Response) {
    const { buffer, ext } = await this.booksService.downloadThumbnail(id);
    const mimeMap: Record<string, string> = {
      jpg: 'image/jpeg',
      jpeg: 'image/jpeg',
      png: 'image/png',
      webp: 'image/webp',
    };
    res.setHeader('Content-Type', mimeMap[ext] ?? 'application/octet-stream');
    res.setHeader('Content-Disposition', 'attachment');
    res.send(buffer);
  }

  /**
   * @description 책 파일을 다운로드한다.
   * @param {string} id Book ID
   * @param {Response} res HTTP 응답 객체
   */
  @Get(':id/download')
  @ApiOperation({ summary: '책 파일 다운로드' })
  @ApiResponse({ status: 200, description: '파일 스트림 반환' })
  @ApiResponse({ status: 401, description: '인증 필요' })
  @ApiResponse({ status: 404, description: 'Book 없음 또는 파일 없음' })
  async download(@Param('id') id: string, @Res() res: Response) {
    const { buffer, contentType, filename } =
      await this.booksService.download(id);
    res.setHeader('Content-Type', contentType);
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    res.send(buffer);
  }
}
