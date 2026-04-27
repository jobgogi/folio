/**
 * @description GetBooksQueryDto 유효성 검사 단위 테스트
 * @author 설석주 (ixymori@gmail.com)
 * @since 2026.04.27
 * @version 1.0.0
 * @see GetBooksQueryDto
 */
import { validate } from 'class-validator';
import { plainToInstance } from 'class-transformer';
import { GetBooksQueryDto } from './get-books-query.dto';

describe('GetBooksQueryDto', () => {
  it('기본값만으로 유효성 검사를 통과한다', async () => {
    const dto = plainToInstance(GetBooksQueryDto, {});
    const errors = await validate(dto);
    expect(errors).toHaveLength(0);
  });

  it.each(['recent_opened', 'name', 'recent_added'])(
    '유효한 sort 값 "%s"이면 에러가 없다',
    async (sort) => {
      const dto = plainToInstance(GetBooksQueryDto, { sort });
      const errors = await validate(dto);
      expect(errors).toHaveLength(0);
    },
  );

  it('잘못된 sort 값이면 유효성 검사에 실패한다', async () => {
    const dto = plainToInstance(GetBooksQueryDto, { sort: 'invalid_sort' });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('sort');
  });

  it('page가 0이면 유효성 검사에 실패한다', async () => {
    const dto = plainToInstance(GetBooksQueryDto, { page: 0 });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('page');
  });

  it('limit이 0이면 유효성 검사에 실패한다', async () => {
    const dto = plainToInstance(GetBooksQueryDto, { limit: 0 });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('limit');
  });
});
