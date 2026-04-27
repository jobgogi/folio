/**
 * @description 유저 관리 기능을 제공하는 NestJS 모듈
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see UsersController, UsersService
 */
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import nasConfig from '../config/nas.config';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';

@Module({
  imports: [ConfigModule.forFeature(nasConfig)],
  controllers: [UsersController],
  providers: [UsersService],
})
export class UsersModule {}
