import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsOptional, IsString } from 'class-validator';

export class FileDto {
  @ApiProperty({ example: 'file-001' })
  @IsString()
  id: string;

  @ApiProperty({ example: 'book.pdf' })
  @IsString()
  name: string;

  @ApiProperty({ enum: ['pdf', 'epub', 'unknown'], example: 'pdf' })
  @IsIn(['pdf', 'epub', 'unknown'])
  type: 'pdf' | 'epub' | 'unknown';

  @ApiProperty({ example: '/pdf/book.pdf' })
  @IsString()
  path: string;

  @ApiPropertyOptional({ example: '2026-04-27T10:00:00.000', nullable: true })
  @IsOptional()
  @IsString()
  lastOpenedAt: string | null;
}
