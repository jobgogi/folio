/**
 * @description 애플리케이션 루트 모듈
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see FilesModule, AuthModule, SyncModule, BooksModule
 */
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { FilesModule } from './files/files.module';
import { AuthModule } from './auth/auth.module';
import { PrismaModule } from './prisma/prisma.module';
import { SyncModule } from './sync/sync.module';
import { BooksModule } from './books/books.module';
import { UsersModule } from './users/users.module';
import { validationSchema } from './config/validation.schema';
import appConfig from './config/app.config';
import databaseConfig from './config/database.config';
import { AppController } from './app.controller';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [appConfig, databaseConfig],
      validationSchema,
    }),
    PrismaModule,
    FilesModule,
    AuthModule,
    SyncModule,
    BooksModule,
    UsersModule,
  ],
  controllers: [AppController],
})
export class AppModule {}
