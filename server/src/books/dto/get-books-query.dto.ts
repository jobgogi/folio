/**
 * @description GET /v1/books 쿼리 파라미터 DTO
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksController
 */
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsIn, IsInt, IsOptional, Min } from 'class-validator';

export type SortOption = 'recent_opened' | 'name' | 'recent_added';

export class GetBooksQueryDto {
  @ApiPropertyOptional({ example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page: number = 1;

  @ApiPropertyOptional({ example: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit: number = 20;

  @ApiPropertyOptional({
    enum: ['recent_opened', 'name', 'recent_added'],
    example: 'recent_opened',
  })
  @IsOptional()
  @IsIn(['recent_opened', 'name', 'recent_added'])
  sort: SortOption = 'recent_opened';
}
