import { Test, TestingModule } from '@nestjs/testing';
import { NotFoundException } from '@nestjs/common';
import { FilesService } from './files.service';
import { FileDto } from './dto/file.dto';

describe('FilesService', () => {
  let service: FilesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [FilesService],
    }).compile();

    service = module.get<FilesService>(FilesService);
  });

  describe('findAll', () => {
    it('파일 목록을 반환한다', async () => {
      // Act
      const result = await service.findAll();
      // Assert
      expect(result).toBeInstanceOf(Array);
      expect(result.length).toBeGreaterThan(0);
    });

    it('반환된 항목은 FileDto 형태이다', async () => {
      const result = await service.findAll();
      const file = result[0];
      expect(file).toHaveProperty('id');
      expect(file).toHaveProperty('name');
      expect(file).toHaveProperty('type');
      expect(file).toHaveProperty('path');
    });

    it('반환된 파일의 type은 pdf 또는 epub 또는 unknown이다', async () => {
      const result = await service.findAll();
      result.forEach((file) => {
        expect(['pdf', 'epub', 'unknown']).toContain(file.type);
      });
    });
  });

  describe('findOne', () => {
    it('id로 단일 파일을 반환한다', async () => {
      // Arrange
      const files = await service.findAll();
      const target = files[0];
      // Act
      const result = await service.findOne(target.id);
      // Assert
      expect(result).not.toBeNull();
      expect(result!.id).toBe(target.id);
    });

    it('존재하지 않는 id는 NotFoundException을 던진다', async () => {
      await expect(service.findOne('not-exist-id')).rejects.toThrow(NotFoundException);
    });
  });
});
