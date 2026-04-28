/**
 * @description JWT Passport 전략 — 쿠키 및 Bearer 토큰을 검증하고 payload를 반환한다
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AuthModule
 */
import { Inject, Injectable } from '@nestjs/common';
import type { ConfigType } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { Request } from 'express';
import { ExtractJwt, Strategy } from 'passport-jwt';
import authConfig from '../config/auth.config';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    @Inject(authConfig.KEY)
    config: ConfigType<typeof authConfig>,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromExtractors([
        (req: Request) => req?.cookies?.access_token ?? null,
        ExtractJwt.fromAuthHeaderAsBearerToken(),
      ]),
      ignoreExpiration: false,
      secretOrKey: config.jwtSecret,
    });
  }

  /**
   * @description 검증된 JWT payload를 반환한다.
   * @param {Record<string, unknown>} payload 디코딩된 JWT payload
   * @returns {Record<string, unknown>} payload 그대로 반환 (req.user에 주입됨)
   */
  validate(payload: Record<string, unknown>): Record<string, unknown> {
    return payload;
  }
}
