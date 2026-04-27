import { Controller, Get, Param } from '@nestjs/common';
import { FilesService } from './files.service';
import { FileDto } from './dto/file.dto';

@Controller('files')
export class FilesController {
  constructor(private readonly filesService: FilesService) {}

  @Get()
  findAll(): Promise<FileDto[]> {
    return this.filesService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string): Promise<FileDto | null> {
    return this.filesService.findOne(id);
  }
}
