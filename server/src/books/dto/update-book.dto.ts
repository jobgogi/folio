/**
 * @description PATCH /v1/books/:id 요청 DTO
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksController
 */
import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsDateString, IsIn, IsOptional, IsString } from 'class-validator';

export class UpdateBookDto {
  @ApiPropertyOptional({ example: 'Clean Code' })
  @IsOptional()
  @IsString()
  title?: string;

  @ApiPropertyOptional({ example: 'Robert C. Martin' })
  @IsOptional()
  @IsString()
  author?: string;

  @ApiPropertyOptional({ example: '9780132350884' })
  @IsOptional()
  @IsString()
  isbn?: string;

  @ApiPropertyOptional({ example: 'Prentice Hall' })
  @IsOptional()
  @IsString()
  publisher?: string;

  @ApiPropertyOptional({ example: '2008-08-01' })
  @IsOptional()
  @IsDateString()
  publishedAt?: string;

  @ApiPropertyOptional({ example: 'https://example.com/cover.jpg' })
  @IsOptional()
  @IsString()
  thumbnail?: string;

  @ApiPropertyOptional({ enum: ['LTR', 'RTL', 'TTB'] })
  @IsOptional()
  @IsIn(['LTR', 'RTL', 'TTB'])
  readingDirection?: 'LTR' | 'RTL' | 'TTB';
}
