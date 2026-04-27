/**
 * @description PrismaService 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see PrismaService
 */
import { Test, TestingModule } from '@nestjs/testing';
import { ConfigService } from '@nestjs/config';

jest.mock('@prisma/adapter-pg', () => ({
  PrismaPg: jest.fn().mockImplementation(() => ({})),
}));

jest.mock('../../prisma/generated/client', () => ({
  PrismaClient: class {
    constructor(_opts?: unknown) {}
  },
}));

import { PrismaService } from './prisma.service';

describe('PrismaService', () => {
  let service: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PrismaService,
        {
          provide: ConfigService,
          useValue: { get: jest.fn().mockReturnValue('postgresql://test:test@localhost:5432/test') },
        },
      ],
    }).compile();

    service = module.get<PrismaService>(PrismaService);
  });

  it('ConfigService로부터 DATABASE_URL을 읽어 인스턴스를 생성한다', () => {
    // Assert
    expect(service).toBeInstanceOf(PrismaService);
  });
});
