/**
 * @description 유저 관리 비즈니스 로직
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see UsersController
 */
import {
  BadRequestException,
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { ConfigType } from '@nestjs/config';
import * as bcrypt from 'bcrypt';
import * as fs from 'fs/promises';
import * as path from 'path';
import nasConfig from '../config/nas.config';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdatePasswordDto } from './dto/update-password.dto';

const ALLOWED_AVATAR_EXTS = ['jpg', 'jpeg', 'png', 'webp'];
const MAX_AVATAR_SIZE = 2 * 1024 * 1024;

@Injectable()
export class UsersService {
  constructor(
    @Inject(nasConfig.KEY)
    private readonly nas: ConfigType<typeof nasConfig>,
    private readonly prisma: PrismaService,
  ) {}

  /**
   * @description 유저를 생성하고 password를 제외한 정보를 반환한다.
   * @param {CreateUserDto} dto 유저 생성 DTO
   * @returns 생성된 유저 (password 제외)
   * @throws {ConflictException} 중복 username 시
   */
  async createUser(dto: CreateUserDto) {
    const hashed = await bcrypt.hash(dto.password, 10);
    try {
      const user = await this.prisma.user.create({
        data: { username: dto.username, password: hashed, role: dto.role },
        select: {
          id: true,
          username: true,
          role: true,
          avatar: true,
          createdAt: true,
          updatedAt: true,
        },
      });
      return user;
    } catch (err: any) {
      if (err?.code === 'P2002')
        throw new ConflictException('이미 존재하는 username입니다.');
      throw err;
    }
  }

  /**
   * @description 유저 목록을 반환한다 (password 제외).
   * @returns 유저 배열
   */
  async findAll() {
    return this.prisma.user.findMany({
      select: {
        id: true,
        username: true,
        role: true,
        avatar: true,
        createdAt: true,
        updatedAt: true,
      },
    });
  }

  /**
   * @description 유저를 삭제한다.
   * @param {string} id 삭제할 유저 ID
   * @param {string} requesterId 요청자 ID
   * @throws {NotFoundException} 유저 미존재 시
   * @throws {BadRequestException} 본인 또는 ROOT 계정 삭제 시도 시
   */
  async deleteUser(id: string, requesterId: string): Promise<void> {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('유저를 찾을 수 없습니다.');
    if (id === requesterId)
      throw new BadRequestException('본인 계정은 삭제할 수 없습니다.');
    if (user.role === 'ROOT')
      throw new BadRequestException('ROOT 계정은 삭제할 수 없습니다.');

    await this.prisma.user.delete({ where: { id } });
  }

  /**
   * @description 유저의 비밀번호를 변경한다.
   * @param {string} id 대상 유저 ID
   * @param {UpdatePasswordDto} dto 새 비밀번호 DTO
   * @throws {NotFoundException} 유저 미존재 시
   */
  async updatePassword(id: string, dto: UpdatePasswordDto): Promise<void> {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('유저를 찾을 수 없습니다.');

    const hashed = await bcrypt.hash(dto.password, 10);
    await this.prisma.user.update({
      where: { id },
      data: { password: hashed },
    });
  }

  /**
   * @description 프로필 사진을 NAS에 저장하고 avatar 경로를 업데이트한다.
   * @param {string} id 유저 ID
   * @param {Express.Multer.File} file 업로드 파일
   * @returns {{ avatarPath: string }} 저장된 avatar 경로
   * @throws {NotFoundException} 유저 미존재 시
   * @throws {BadRequestException} 허용되지 않는 확장자 또는 2MB 초과 시
   */
  async uploadAvatar(
    id: string,
    file: Express.Multer.File,
  ): Promise<{ avatarPath: string }> {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('유저를 찾을 수 없습니다.');

    const ext = path.extname(file.originalname).replace('.', '').toLowerCase();
    if (!ALLOWED_AVATAR_EXTS.includes(ext)) {
      throw new BadRequestException(
        `허용된 확장자: ${ALLOWED_AVATAR_EXTS.join(', ')}`,
      );
    }
    if (file.size > MAX_AVATAR_SIZE) {
      throw new BadRequestException('파일 크기는 2MB를 초과할 수 없습니다.');
    }

    if (user.avatar) await fs.rm(user.avatar, { force: true });

    const dir = path.join(this.nas.mountPath!, '.avatars');
    await fs.mkdir(dir, { recursive: true });
    const avatarPath = path.join(dir, `${id}.${ext}`);
    await fs.writeFile(avatarPath, file.buffer);

    await this.prisma.user.update({
      where: { id },
      data: { avatar: avatarPath },
    });
    return { avatarPath };
  }

  /**
   * @description 프로필 사진 파일을 읽어 버퍼와 확장자를 반환한다.
   * @param {string} id 유저 ID
   * @returns {{ buffer: Buffer; ext: string }}
   * @throws {NotFoundException} 유저 미존재 또는 avatar 없음 시
   */
  async getAvatar(id: string): Promise<{ buffer: Buffer; ext: string }> {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user) throw new NotFoundException('유저를 찾을 수 없습니다.');
    if (!user.avatar) throw new NotFoundException('프로필 사진이 없습니다.');

    const buffer = await fs.readFile(user.avatar);
    const ext = path.extname(user.avatar).replace('.', '').toLowerCase();
    return { buffer, ext };
  }
}
