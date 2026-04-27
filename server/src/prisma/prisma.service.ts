/**
 * @description Prisma 클라이언트 래퍼 서비스 — DB 연결 생명주기 관리
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AppModule
 */
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { PrismaClient } from '../../prisma/generated/client';

@Injectable()
export class PrismaService extends PrismaClient {
  constructor(private readonly configService: ConfigService) {
    const adapter = new PrismaPg({
      connectionString: configService.get<string>('DATABASE_URL') ?? '',
    });
    super({ adapter });
  }
}
