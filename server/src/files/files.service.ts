/**
 * @description 파일 목록 및 단일 파일 조회 비즈니스 로직
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see FilesController
 */
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
  /**
   * @description 전체 파일 목록을 반환한다.
   * @returns {Promise<FileDto[]>} 파일 목록
   */
  async findAll(): Promise<FileDto[]> {
    return MOCK_FILES;
  }

  /**
   * @description id로 단일 파일을 조회한다.
   * @param {string} id 파일 고유 식별자
   * @returns {Promise<FileDto>} 파일 정보
   * @throws {NotFoundException} 해당 id의 파일이 없을 시
   */
  async findOne(id: string): Promise<FileDto> {
    const file = MOCK_FILES.find((f) => f.id === id) ?? null;
    if (!file) throw new NotFoundException(`File ${id} not found`);
    return file;
  }
}
