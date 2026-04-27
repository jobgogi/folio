/**
 * @description UsersService 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see UsersService
 */
import { Test, TestingModule } from '@nestjs/testing';
import { BadRequestException, ConflictException, NotFoundException } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import * as fs from 'fs/promises';
import nasConfig from '../config/nas.config';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdatePasswordDto } from './dto/update-password.dto';

jest.mock('fs/promises');
const mockFs = fs as jest.Mocked<typeof fs>;

const mockPrisma = {
  user: {
    create: jest.fn(),
    findMany: jest.fn(),
    findUnique: jest.fn(),
    delete: jest.fn(),
    update: jest.fn(),
  },
};

const MOCK_NAS_PATH = '/mnt/nas';

describe('UsersService', () => {
  let service: UsersService;

  beforeEach(async () => {
    jest.clearAllMocks();

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: nasConfig.KEY, useValue: { mountPath: MOCK_NAS_PATH } },
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  describe('createUser', () => {
    it('유저를 생성하고 반환한다', async () => {
      // Arrange
      const dto: CreateUserDto = { username: 'newuser', password: 'password123' };
      mockPrisma.user.create.mockResolvedValue({ id: 'uuid-1', username: 'newuser', role: 'USER' });
      // Act
      const result = await service.createUser(dto);
      // Assert
      expect(result).toHaveProperty('id');
      expect(result.username).toBe('newuser');
      expect(result).not.toHaveProperty('password');
    });

    it('password를 bcrypt로 해싱하여 저장한다', async () => {
      // Arrange
      const dto: CreateUserDto = { username: 'newuser', password: 'password123' };
      mockPrisma.user.create.mockResolvedValue({ id: 'uuid-1', username: 'newuser', role: 'USER' });
      // Act
      await service.createUser(dto);
      // Assert
      const createCall = mockPrisma.user.create.mock.calls[0][0];
      const isHashed = await bcrypt.compare('password123', createCall.data.password);
      expect(isHashed).toBe(true);
    });

    it('중복 username이면 ConflictException을 던진다', async () => {
      // Arrange
      const dto: CreateUserDto = { username: 'existing', password: 'password123' };
      mockPrisma.user.create.mockRejectedValue({ code: 'P2002' });
      // Act & Assert
      await expect(service.createUser(dto)).rejects.toThrow(ConflictException);
    });
  });

  describe('findAll', () => {
    it('유저 목록을 반환한다', async () => {
      // Arrange
      mockPrisma.user.findMany.mockResolvedValue([
        { id: 'uuid-1', username: 'admin', role: 'ROOT' },
        { id: 'uuid-2', username: 'user1', role: 'USER' },
      ]);
      // Act
      const result = await service.findAll();
      // Assert
      expect(result).toBeInstanceOf(Array);
      expect(result).toHaveLength(2);
    });

    it('반환된 항목에 password가 포함되지 않는다', async () => {
      // Arrange
      mockPrisma.user.findMany.mockResolvedValue([
        { id: 'uuid-1', username: 'admin', role: 'ROOT' },
      ]);
      // Act
      const result = await service.findAll();
      // Assert
      result.forEach((user) => expect(user).not.toHaveProperty('password'));
    });
  });

  describe('deleteUser', () => {
    it('유저를 삭제한다', async () => {
      // Arrange
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'uuid-2', username: 'user1', role: 'USER' });
      mockPrisma.user.delete.mockResolvedValue({});
      // Act & Assert
      await expect(service.deleteUser('uuid-2', 'uuid-1')).resolves.not.toThrow();
      expect(mockPrisma.user.delete).toHaveBeenCalledWith({ where: { id: 'uuid-2' } });
    });

    it('본인 계정은 삭제할 수 없다', async () => {
      // Arrange
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'uuid-1', username: 'admin', role: 'USER' });
      // Act & Assert
      await expect(service.deleteUser('uuid-1', 'uuid-1')).rejects.toThrow(BadRequestException);
    });

    it('ROOT 계정은 삭제할 수 없다', async () => {
      // Arrange
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'uuid-root', username: 'root', role: 'ROOT' });
      // Act & Assert
      await expect(service.deleteUser('uuid-root', 'uuid-other')).rejects.toThrow(BadRequestException);
    });

    it('존재하지 않는 id면 NotFoundException을 던진다', async () => {
      // Arrange
      mockPrisma.user.findUnique.mockResolvedValue(null);
      // Act & Assert
      await expect(service.deleteUser('not-exist', 'uuid-1')).rejects.toThrow(NotFoundException);
    });
  });

  describe('updatePassword', () => {
    it('비밀번호를 변경한다', async () => {
      // Arrange
      const dto: UpdatePasswordDto = { password: 'newpassword123' };
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'uuid-1', username: 'user1', role: 'USER' });
      mockPrisma.user.update.mockResolvedValue({});
      // Act & Assert
      await expect(service.updatePassword('uuid-1', dto)).resolves.not.toThrow();
    });

    it('비밀번호를 bcrypt로 해싱하여 저장한다', async () => {
      // Arrange
      const dto: UpdatePasswordDto = { password: 'newpassword123' };
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'uuid-1', username: 'user1', role: 'USER' });
      mockPrisma.user.update.mockResolvedValue({});
      // Act
      await service.updatePassword('uuid-1', dto);
      // Assert
      const updateCall = mockPrisma.user.update.mock.calls[0][0];
      const isHashed = await bcrypt.compare('newpassword123', updateCall.data.password);
      expect(isHashed).toBe(true);
    });

    it('존재하지 않는 유저면 NotFoundException을 던진다', async () => {
      // Arrange
      const dto: UpdatePasswordDto = { password: 'newpassword123' };
      mockPrisma.user.findUnique.mockResolvedValue(null);
      // Act & Assert
      await expect(service.updatePassword('not-exist', dto)).rejects.toThrow(NotFoundException);
    });
  });

  describe('uploadAvatar', () => {
    const makeFile = (name: string, size: number): Express.Multer.File =>
      ({ originalname: name, size, buffer: Buffer.from('imgdata') } as Express.Multer.File);

    it('jpg 파일을 업로드하고 avatar 경로를 반영한다', async () => {
      // Arrange
      const file = makeFile('photo.jpg', 1024 * 100);
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'uuid-1', username: 'user1', role: 'USER', avatar: null });
      mockFs.mkdir.mockResolvedValue(undefined);
      mockFs.writeFile.mockResolvedValue(undefined);
      mockPrisma.user.update.mockResolvedValue({ id: 'uuid-1', avatar: `${MOCK_NAS_PATH}/.avatars/uuid-1.jpg` });
      // Act
      const result = await service.uploadAvatar('uuid-1', file);
      // Assert
      expect(result.avatarPath).toContain('uuid-1.jpg');
    });

    it('png 파일을 업로드하고 avatar 경로를 반영한다', async () => {
      // Arrange
      const file = makeFile('photo.png', 1024 * 100);
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'uuid-1', username: 'user1', role: 'USER', avatar: null });
      mockFs.mkdir.mockResolvedValue(undefined);
      mockFs.writeFile.mockResolvedValue(undefined);
      mockPrisma.user.update.mockResolvedValue({ id: 'uuid-1', avatar: `${MOCK_NAS_PATH}/.avatars/uuid-1.png` });
      // Act
      const result = await service.uploadAvatar('uuid-1', file);
      // Assert
      expect(result.avatarPath).toContain('uuid-1.png');
    });

    it('허용되지 않는 확장자면 BadRequestException을 던진다', async () => {
      // Arrange
      const file = makeFile('photo.gif', 1024 * 100);
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'uuid-1', username: 'user1', role: 'USER', avatar: null });
      // Act & Assert
      await expect(service.uploadAvatar('uuid-1', file)).rejects.toThrow(BadRequestException);
    });

    it('2MB 초과 파일이면 BadRequestException을 던진다', async () => {
      // Arrange
      const file = makeFile('photo.jpg', 1024 * 1024 * 3);
      mockPrisma.user.findUnique.mockResolvedValue({ id: 'uuid-1', username: 'user1', role: 'USER', avatar: null });
      // Act & Assert
      await expect(service.uploadAvatar('uuid-1', file)).rejects.toThrow(BadRequestException);
    });

    it('기존 avatar가 있으면 덮어쓴다', async () => {
      // Arrange
      const file = makeFile('photo.png', 1024 * 100);
      mockPrisma.user.findUnique.mockResolvedValue({
        id: 'uuid-1', username: 'user1', role: 'USER',
        avatar: `${MOCK_NAS_PATH}/.avatars/uuid-1.jpg`,
      });
      mockFs.rm.mockResolvedValue(undefined);
      mockFs.mkdir.mockResolvedValue(undefined);
      mockFs.writeFile.mockResolvedValue(undefined);
      mockPrisma.user.update.mockResolvedValue({ id: 'uuid-1', avatar: `${MOCK_NAS_PATH}/.avatars/uuid-1.png` });
      // Act
      const result = await service.uploadAvatar('uuid-1', file);
      // Assert
      expect(mockFs.rm).toHaveBeenCalled();
      expect(result.avatarPath).toContain('uuid-1.png');
    });

    it('존재하지 않는 유저면 NotFoundException을 던진다', async () => {
      // Arrange
      const file = makeFile('photo.jpg', 1024 * 100);
      mockPrisma.user.findUnique.mockResolvedValue(null);
      // Act & Assert
      await expect(service.uploadAvatar('uuid-1', file)).rejects.toThrow(NotFoundException);
    });
  });

  describe('getAvatar', () => {
    it('avatar 파일 버퍼와 확장자를 반환한다', async () => {
      // Arrange
      mockPrisma.user.findUnique.mockResolvedValue({
        id: 'uuid-1', username: 'user1', role: 'USER',
        avatar: `${MOCK_NAS_PATH}/.avatars/uuid-1.jpg`,
      });
      mockFs.readFile.mockResolvedValue(Buffer.from('imgdata') as any);
      // Act
      const result = await service.getAvatar('uuid-1');
      // Assert
      expect(result.buffer).toBeInstanceOf(Buffer);
      expect(result.ext).toBe('jpg');
    });

    it('존재하지 않는 유저면 NotFoundException을 던진다', async () => {
      // Arrange
      mockPrisma.user.findUnique.mockResolvedValue(null);
      // Act & Assert
      await expect(service.getAvatar('not-exist')).rejects.toThrow(NotFoundException);
    });

    it('avatar가 없으면 NotFoundException을 던진다', async () => {
      // Arrange
      mockPrisma.user.findUnique.mockResolvedValue({
        id: 'uuid-1', username: 'user1', role: 'USER', avatar: null,
      });
      // Act & Assert
      await expect(service.getAvatar('uuid-1')).rejects.toThrow(NotFoundException);
    });
  });
});
