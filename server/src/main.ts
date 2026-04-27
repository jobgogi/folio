/**
 * @description 애플리케이션 진입점 — NestJS 서버 부트스트랩
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see AppModule
 */
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import type { ConfigType } from '@nestjs/config';
import cookieParser from 'cookie-parser';
import { AppModule } from './app.module';
import appConfig from './config/app.config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.use(cookieParser());

  const config = app.get<ConfigType<typeof appConfig>>(appConfig.KEY);
  app.enableCors({
    origin: config.corsOrigin,
    credentials: true,
  });

  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  const swaggerConfig = new DocumentBuilder()
    .setTitle('Folio API')
    .setDescription('PDF · ePub 뷰어 API 문서')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('v1/docs', app, document);

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
