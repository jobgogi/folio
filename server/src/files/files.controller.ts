import { Controller, Get, Param } from '@nestjs/common';
import { ApiOkResponse, ApiNotFoundResponse, ApiTags } from '@nestjs/swagger';
import { FilesService } from './files.service';
import { FileDto } from './dto/file.dto';

@ApiTags('files')
@Controller('v1/files')
export class FilesController {
  constructor(private readonly filesService: FilesService) {}

  @Get()
  @ApiOkResponse({ type: [FileDto], description: '파일 목록 반환' })
  findAll(): Promise<FileDto[]> {
    return this.filesService.findAll();
  }

  @Get(':id')
  @ApiOkResponse({ type: FileDto, description: '단일 파일 반환' })
  @ApiNotFoundResponse({ description: '파일 없음' })
  findOne(@Param('id') id: string): Promise<FileDto> {
    return this.filesService.findOne(id);
  }
}
