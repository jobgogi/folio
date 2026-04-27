/**
 * @description 역할 기반 접근 제어 가드
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see Roles
 */
import { CanActivate, ExecutionContext, ForbiddenException, Injectable } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { UserRole } from '../../../prisma/generated/client';
import { ROLES_KEY } from '../decorators/roles.decorator';

@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  /**
   * @description 요청자의 role이 핸들러에 설정된 required roles를 충족하는지 검사한다.
   * @param {ExecutionContext} context 실행 컨텍스트
   * @returns {boolean} 접근 허용 여부
   * @throws {ForbiddenException} 권한 부족 시
   */
  canActivate(context: ExecutionContext): boolean {
    const required = this.reflector.getAllAndOverride<UserRole[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!required || required.length === 0) return true;

    const { user } = context.switchToHttp().getRequest();
    if (!required.includes(user?.role)) {
      throw new ForbiddenException('접근 권한이 없습니다.');
    }
    return true;
  }
}
