/**
 * @description PrismaService 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see PrismaService
 */
import { Test, TestingModule } from '@nestjs/testing';

jest.mock('@prisma/adapter-pg', () => ({
  PrismaPg: jest.fn().mockImplementation(() => ({})),
}));

jest.mock('../../prisma/generated/client', () => ({
  PrismaClient: class {
    constructor(_opts?: unknown) {}
  },
}));

import databaseConfig from '../config/database.config';
import { PrismaService } from './prisma.service';

describe('PrismaService', () => {
  let service: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PrismaService,
        {
          provide: databaseConfig.KEY,
          useValue: { url: 'postgresql://test:test@localhost:5432/test' },
        },
      ],
    }).compile();

    service = module.get<PrismaService>(PrismaService);
  });

  it('databaseConfig로부터 url을 읽어 인스턴스를 생성한다', () => {
    expect(service).toBeInstanceOf(PrismaService);
  });
});
