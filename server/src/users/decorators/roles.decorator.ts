/**
 * @description 역할 기반 접근 제어 데코레이터
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see RolesGuard
 */
import { SetMetadata } from '@nestjs/common';
import { UserRole } from '../../../prisma/generated/client';

export const ROLES_KEY = 'roles';
export const Roles = (...roles: UserRole[]) => SetMetadata(ROLES_KEY, roles);
