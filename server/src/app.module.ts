/**
 * @description 애플리케이션 루트 모듈
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see FilesModule, AuthModule
 */
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { FilesModule } from './files/files.module';
import { AuthModule } from './auth/auth.module';
import { PrismaModule } from './prisma/prisma.module';
import { validationSchema } from './config/validation.schema';
import databaseConfig from './config/database.config';
import { AppController } from './app.controller';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, load: [databaseConfig], validationSchema }),
    PrismaModule,
    FilesModule,
    AuthModule,
  ],
  controllers: [AppController],
})
export class AppModule {}
