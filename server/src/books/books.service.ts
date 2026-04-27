/**
 * @description Book 조회 및 수정 비즈니스 로직
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksModule
 */
import { BadRequestException, Inject, Injectable, NotFoundException } from '@nestjs/common';
import { ConfigType } from '@nestjs/config';
import * as fs from 'fs/promises';
import * as path from 'path';
import { Prisma } from '../../prisma/generated/client';
import nasConfig from '../config/nas.config';
import { PrismaService } from '../prisma/prisma.service';
import { GetBooksQueryDto, SortOption } from './dto/get-books-query.dto';
import { UpdateBookDto } from './dto/update-book.dto';

const THUMBNAIL_ALLOWED_EXTS = ['jpg', 'jpeg', 'png'];
const THUMBNAIL_MAX_SIZE = 5 * 1024 * 1024;

const SORT_MAP: Record<SortOption, Prisma.BookOrderByWithRelationInput> = {
  recent_opened: { lastOpenedAt: 'desc' },
  name: { title: 'asc' },
  recent_added: { createdAt: 'desc' },
};

@Injectable()
export class BooksService {
  constructor(
    private readonly prisma: PrismaService,
    @Inject(nasConfig.KEY)
    private readonly nas: ConfigType<typeof nasConfig>,
  ) {}

  /**
   * @description Book 목록을 페이징 및 정렬하여 반환한다.
   * @param {GetBooksQueryDto} query 페이징/정렬 쿼리
   * @returns 페이징된 Book 목록과 메타 정보
   */
  async findAll(query: GetBooksQueryDto) {
    const { page, limit, sort } = query;
    const skip = (page - 1) * limit;
    const orderBy = SORT_MAP[sort];

    const [data, total] = await Promise.all([
      this.prisma.book.findMany({ skip, take: limit, orderBy }),
      this.prisma.book.count(),
    ]);

    return {
      data,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * @description 단일 Book을 반환한다.
   * @param {string} id Book ID
   * @returns Book
   * @throws {NotFoundException} 존재하지 않는 id
   */
  async findOne(id: string) {
    const book = await this.prisma.book.findUnique({ where: { id } });
    if (!book) throw new NotFoundException(`Book ${id} not found`);
    return book;
  }

  /**
   * @description Book 메타데이터를 수정한다.
   * @param {string} id Book ID
   * @param {UpdateBookDto} dto 수정할 필드
   * @returns 수정된 Book
   * @throws {NotFoundException} 존재하지 않는 id
   */
  async update(id: string, dto: UpdateBookDto) {
    await this.findOne(id);
    return this.prisma.book.update({
      where: { id },
      data: {
        ...dto,
        publishedAt: dto.publishedAt ? new Date(dto.publishedAt) : undefined,
      },
    });
  }

  /**
   * @description 책 파일을 읽어 버퍼와 Content-Type, 파일명을 반환한다.
   * @param {string} id Book ID
   * @returns {{ buffer: Buffer; contentType: string; filename: string }}
   * @throws {NotFoundException} Book 미존재 또는 파일 없음 시
   */
  async download(id: string): Promise<{ buffer: Buffer; contentType: string; filename: string }> {
    const book = await this.prisma.book.findUnique({ where: { id } });
    if (!book) throw new NotFoundException(`Book ${id} not found`);

    try {
      const buffer = await fs.readFile(book.path);
      const contentType = book.type === 'PDF' ? 'application/pdf' : 'application/epub+zip';
      const filename = path.basename(book.path);
      return { buffer, contentType, filename };
    } catch {
      throw new NotFoundException('파일을 찾을 수 없습니다.');
    }
  }

  /**
   * @description 마지막 열람 시각을 현재 시각으로 갱신한다.
   * @param {string} id Book ID
   * @returns 갱신된 Book
   * @throws {NotFoundException} 존재하지 않는 id
   */
  async open(id: string) {
    await this.findOne(id);
    return this.prisma.book.update({
      where: { id },
      data: { lastOpenedAt: new Date() },
    });
  }

  /**
   * @description 썸네일 이미지를 업로드하고 Book에 경로를 반영한다.
   * @param {string} id Book ID
   * @param {Express.Multer.File} file 업로드 파일
   * @returns {{ thumbnailPath: string }} 저장된 썸네일 경로
   * @throws {NotFoundException} Book 미존재 시
   * @throws {BadRequestException} 허용되지 않는 확장자 또는 5MB 초과 시
   */
  async uploadThumbnail(id: string, file: Express.Multer.File): Promise<{ thumbnailPath: string }> {
    const book = await this.prisma.book.findUnique({ where: { id } });
    if (!book) throw new NotFoundException(`Book ${id} not found`);

    const ext = path.extname(file.originalname).slice(1).toLowerCase();
    if (!THUMBNAIL_ALLOWED_EXTS.includes(ext)) {
      throw new BadRequestException(`허용되지 않는 확장자입니다: ${ext}`);
    }
    if (file.size > THUMBNAIL_MAX_SIZE) {
      throw new BadRequestException('썸네일은 5MB를 초과할 수 없습니다.');
    }

    if (book.thumbnail) {
      await fs.rm(book.thumbnail, { force: true });
    }

    const thumbnailDir = path.join(this.nas.mountPath!, '.thumbnails');
    await fs.mkdir(thumbnailDir, { recursive: true });

    const thumbnailPath = path.join(thumbnailDir, `${id}.${ext}`);
    await fs.writeFile(thumbnailPath, file.buffer);

    await this.prisma.book.update({
      where: { id },
      data: { thumbnail: thumbnailPath },
    });

    return { thumbnailPath };
  }
}
