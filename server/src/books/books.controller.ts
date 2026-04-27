/**
 * @description Book 조회 및 수정 API 컨트롤러
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksModule
 */
import { Body, Controller, Get, Param, Patch, Query } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import { BooksService } from './books.service';
import { GetBooksQueryDto } from './dto/get-books-query.dto';
import { UpdateBookDto } from './dto/update-book.dto';

@ApiTags('books')
@Controller('v1/books')
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
  @ApiResponse({ status: 404, description: 'Book 없음' })
  open(@Param('id') id: string) {
    return this.booksService.open(id);
  }
}
