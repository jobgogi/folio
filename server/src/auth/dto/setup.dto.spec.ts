/**
 * @description SetupDto 유효성 검사 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see SetupDto
 */
import { validate } from 'class-validator';
import { plainToInstance } from 'class-transformer';
import { SetupDto } from './setup.dto';

describe('SetupDto', () => {
  it('유효한 username과 password면 에러가 없다', async () => {
    const dto = plainToInstance(SetupDto, {
      username: 'admin',
      password: 'password123',
    });
    const errors = await validate(dto);
    expect(errors).toHaveLength(0);
  });

  it('password가 8자 미만이면 유효성 검사에 실패한다', async () => {
    const dto = plainToInstance(SetupDto, {
      username: 'admin',
      password: '1234567',
    });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('password');
  });

  it('username이 비어있으면 유효성 검사에 실패한다', async () => {
    const dto = plainToInstance(SetupDto, {
      username: '',
      password: 'password123',
    });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('username');
  });

  it('password가 비어있으면 유효성 검사에 실패한다', async () => {
    const dto = plainToInstance(SetupDto, { username: 'admin', password: '' });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('password');
  });
});
