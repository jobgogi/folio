import { Injectable, NotFoundException } from '@nestjs/common';
import { FileDto } from './dto/file.dto';

const MOCK_FILES: FileDto[] = [
  { id: 'file-001', name: 'sample.pdf', type: 'pdf', path: '/pdf/sample.pdf', lastOpenedAt: null },
  { id: 'file-002', name: 'document.pdf', type: 'pdf', path: '/pdf/document.pdf', lastOpenedAt: null },
  { id: 'file-003', name: 'novel.epub', type: 'epub', path: '/epub/novel.epub', lastOpenedAt: null },
  { id: 'file-004', name: 'guide.epub', type: 'epub', path: '/epub/guide.epub', lastOpenedAt: null },
];

@Injectable()
export class FilesService {
  async findAll(): Promise<FileDto[]> {
    return MOCK_FILES;
  }

  async findOne(id: string): Promise<FileDto> {
    const file = MOCK_FILES.find((f) => f.id === id) ?? null;
    if (!file) throw new NotFoundException(`File ${id} not found`);
    return file;
  }
}
