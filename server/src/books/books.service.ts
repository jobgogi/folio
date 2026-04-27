/**
 * @description Book 조회 및 수정 비즈니스 로직
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see BooksModule
 */
import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '../../prisma/generated/client';
import { PrismaService } from '../prisma/prisma.service';
import { GetBooksQueryDto, SortOption } from './dto/get-books-query.dto';
import { UpdateBookDto } from './dto/update-book.dto';

const SORT_MAP: Record<SortOption, Prisma.BookOrderByWithRelationInput> = {
  recent_opened: { lastOpenedAt: 'desc' },
  name: { title: 'asc' },
  recent_added: { createdAt: 'desc' },
};

@Injectable()
export class BooksService {
  constructor(private readonly prisma: PrismaService) {}

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
}
