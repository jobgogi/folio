/**
 * @description User 모델 마이그레이션 적용 확인 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see PrismaService
 */
import type { PrismaClient } from '../../prisma/generated/client';
import { UserRole } from '../../prisma/generated/client';

describe('User model', () => {
  it('PrismaClient 타입에 user 델리게이터가 존재한다', () => {
    type UserDelegate = PrismaClient['user'];
    const mock: Partial<UserDelegate> = {};
    expect(mock).toBeDefined();
  });

  it('UserRole enum이 ROOT 값을 갖는다', () => {
    expect(UserRole.ROOT).toBe('ROOT');
  });

  it('UserRole enum이 USER 값을 갖는다', () => {
    expect(UserRole.USER).toBe('USER');
  });
});
