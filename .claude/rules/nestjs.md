# NestJS 규칙

## API 문서
- 모든 컨트롤러, 엔드포인트에 Swagger 데코레이터 필수
- @ApiTags, @ApiOperation, @ApiResponse 반드시 포함
- DTO에 @ApiProperty 필수

## 유효성 검사
- 모든 DTO에 class-validator 적극 활용
- @IsString, @IsNotEmpty, @IsEmail 등 구체적인 데코레이터 사용
- ValidationPipe 전역 적용

## API 버전
- 모든 엔드포인트는 v1/으로 시작
- 예) /v1/files, /v1/auth/login

## 예시

### DTO
\`\`\`typescript
export class LoginDto {
  @ApiProperty({ example: 'admin' })
  @IsString()
  @IsNotEmpty()
  username: string;

  @ApiProperty({ example: 'password123' })
  @IsString()
  @IsNotEmpty()
  password: string;
}
\`\`\`

### Controller
\`\`\`typescript
@ApiTags('auth')
@Controller('v1/auth')
export class AuthController {
  @Post('login')
  @ApiOperation({ summary: '로그인' })
  @ApiResponse({ status: 200, description: '토큰 발급 성공' })
  @ApiResponse({ status: 401, description: '인증 실패' })
  login(@Body() loginDto: LoginDto) {}
}
\`\`\`

## 주석 규칙

### 파일 상단 주석 (필수)
모든 파일 최상단에 TSDoc 형식으로 작성

/**
 * @description 파일 역할 설명
 * @author 설석주 (ixymor@gmail.com)
 * @since YYYY.MM.DD
 * @version 1.0.0
 * @see 참고 파일 또는 None
 */

### 함수 주석 (비즈니스 로직 필수)
/**
 * @description 함수 역할 설명
 * @param {LoginDto} loginDto 로그인 요청 DTO
 * @returns {Promise<string>} 액세스 토큰
 * @throws {UnauthorizedException} 인증 실패 시
 */
async login(loginDto: LoginDto): Promise<string> {}

### 예시 (전체)
/**
 * @description JWT 기반 인증 비즈니스 로직
 * @author 설석주 (ixymor@gmail.com)
 * @since 2024.06.01
 * @version 1.0.0
 * @see AuthController
 */
@Injectable()
export class AuthService {

  /**
   * @description 사용자 로그인 처리 및 JWT 토큰 발급
   * @param {LoginDto} loginDto 로그인 요청 DTO
   * @returns {Promise<string>} 액세스 토큰
   * @throws {UnauthorizedException} 인증 실패 시
   */
  async login(loginDto: LoginDto): Promise<string> {}

  /**
   * @description JWT 토큰 검증 및 사용자 정보 반환
   * @param {string} token JWT 액세스 토큰
   * @returns {Promise<UserPayload>} 사용자 페이로드
   * @throws {UnauthorizedException} 토큰 만료 또는 유효하지 않을 시
   */
  async verify(token: string): Promise<UserPayload> {}
}