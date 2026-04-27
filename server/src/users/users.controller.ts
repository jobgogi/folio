/**
 * @description 유저 관리 REST API 컨트롤러
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see UsersService
 */
import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Req,
  Res,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiConsumes, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import type { Request, Response } from 'express';
import { JwtAuthGuard } from '../auth/jwt.guard';
import { UserRole } from '../../prisma/generated/client';
import { Roles } from './decorators/roles.decorator';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdatePasswordDto } from './dto/update-password.dto';
import { RolesGuard } from './guards/roles.guard';
import { UsersService } from './users.service';

@ApiTags('users')
@ApiBearerAuth()
@Controller('v1/users')
@UseGuards(JwtAuthGuard, RolesGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  /**
   * @description 유저를 생성한다 (ROOT 전용).
   * @param {CreateUserDto} dto 유저 생성 DTO
   * @returns 생성된 유저 (password 제외)
   */
  @Post()
  @Roles(UserRole.ROOT)
  @ApiOperation({ summary: '유저 생성 (ROOT 전용)' })
  @ApiResponse({ status: 201, description: '유저 생성 성공' })
  @ApiResponse({ status: 400, description: 'DTO 유효성 검사 실패' })
  @ApiResponse({ status: 403, description: '권한 없음' })
  @ApiResponse({ status: 409, description: '중복 username' })
  createUser(@Body() dto: CreateUserDto) {
    return this.usersService.createUser(dto);
  }

  /**
   * @description 유저 목록을 반환한다 (ROOT 전용).
   * @returns 유저 배열
   */
  @Get()
  @Roles(UserRole.ROOT)
  @ApiOperation({ summary: '유저 목록 조회 (ROOT 전용)' })
  @ApiResponse({ status: 200, description: '유저 목록 반환' })
  @ApiResponse({ status: 403, description: '권한 없음' })
  findAll() {
    return this.usersService.findAll();
  }

  /**
   * @description 유저를 삭제한다 (ROOT 전용).
   * @param {string} id 삭제할 유저 ID
   * @param {Request} req 요청 객체 (요청자 정보)
   */
  @Delete(':id')
  @Roles(UserRole.ROOT)
  @ApiOperation({ summary: '유저 삭제 (ROOT 전용)' })
  @ApiResponse({ status: 200, description: '삭제 성공' })
  @ApiResponse({ status: 400, description: '본인 또는 ROOT 계정 삭제 불가' })
  @ApiResponse({ status: 403, description: '권한 없음' })
  @ApiResponse({ status: 404, description: '유저 미존재' })
  deleteUser(@Param('id') id: string, @Req() req: Request) {
    const requester = req.user as { id: string };
    return this.usersService.deleteUser(id, requester.id);
  }

  /**
   * @description 비밀번호를 변경한다 (본인 또는 ROOT).
   * @param {string} id 대상 유저 ID
   * @param {UpdatePasswordDto} dto 새 비밀번호 DTO
   */
  @Patch(':id/password')
  @ApiOperation({ summary: '비밀번호 변경 (본인 또는 ROOT)' })
  @ApiResponse({ status: 200, description: '변경 성공' })
  @ApiResponse({ status: 400, description: 'DTO 유효성 검사 실패' })
  @ApiResponse({ status: 403, description: '권한 없음' })
  @ApiResponse({ status: 404, description: '유저 미존재' })
  updatePassword(@Param('id') id: string, @Body() dto: UpdatePasswordDto) {
    return this.usersService.updatePassword(id, dto);
  }

  /**
   * @description 프로필 사진을 업로드한다 (본인 또는 ROOT).
   * @param {string} id 유저 ID
   * @param {Express.Multer.File} file 업로드 파일
   */
  @Post(':id/avatar')
  @UseInterceptors(FileInterceptor('file'))
  @ApiConsumes('multipart/form-data')
  @ApiOperation({ summary: '프로필 사진 업로드 (본인 또는 ROOT)' })
  @ApiResponse({ status: 201, description: '업로드 성공' })
  @ApiResponse({ status: 400, description: '허용되지 않는 확장자 또는 2MB 초과' })
  @ApiResponse({ status: 404, description: '유저 미존재' })
  uploadAvatar(@Param('id') id: string, @UploadedFile() file: Express.Multer.File) {
    return this.usersService.uploadAvatar(id, file);
  }

  /**
   * @description 프로필 사진을 다운로드한다 (인증 필요).
   * @param {string} id 유저 ID
   * @param {Response} res HTTP 응답 객체
   */
  @Get(':id/avatar')
  @ApiOperation({ summary: '프로필 사진 다운로드 (인증 필요)' })
  @ApiResponse({ status: 200, description: '다운로드 성공' })
  @ApiResponse({ status: 404, description: '유저 미존재 또는 사진 없음' })
  async getAvatar(@Param('id') id: string, @Res() res: Response) {
    const { buffer, ext } = await this.usersService.getAvatar(id);
    const mimeMap: Record<string, string> = {
      jpg: 'image/jpeg',
      jpeg: 'image/jpeg',
      png: 'image/png',
      webp: 'image/webp',
    };
    res.setHeader('Content-Type', mimeMap[ext] ?? 'application/octet-stream');
    res.setHeader('Content-Disposition', 'attachment');
    res.send(buffer);
  }
}
