/**
 * @description Prisma 클라이언트 래퍼 서비스 — DB 연결 생명주기 관리
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AppModule
 */
import { Inject, Injectable } from '@nestjs/common';
import { ConfigType } from '@nestjs/config';
import { PrismaPg } from '@prisma/adapter-pg';
import databaseConfig from '../config/database.config';
import { PrismaClient } from '../../prisma/generated/client';

@Injectable()
export class PrismaService extends PrismaClient {
  constructor(
    @Inject(databaseConfig.KEY)
    private readonly database: ConfigType<typeof databaseConfig>,
  ) {
    const adapter = new PrismaPg({ connectionString: database.url ?? '' });
    super({ adapter });
  }
}
