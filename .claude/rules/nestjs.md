# NestJS 규칙

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

## DTO 예시
/**
 * @description 로그인 요청 DTO
 * @author 설석주 (ixymor@gmail.com)
 * @since YYYY.MM.DD
 * @version 1.0.0
 * @see AuthService
 */
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

## Controller 예시
/**
 * @description 인증 API 컨트롤러
 * @author 설석주 (ixymor@gmail.com)
 * @since YYYY.MM.DD
 * @version 1.0.0
 * @see AuthService
 */
@ApiTags('auth')
@Controller('v1/auth')
export class AuthController {

  /**
   * @description 로그인 처리 및 JWT 토큰 발급
   * @param {LoginDto} loginDto 로그인 요청 DTO
   * @returns {Promise<string>} 액세스 토큰
   * @throws {UnauthorizedException} 인증 실패 시
   */
  @Post('login')
  @ApiOperation({ summary: '로그인' })
  @ApiResponse({ status: 200, description: '토큰 발급 성공' })
  @ApiResponse({ status: 401, description: '인증 실패' })
  login(@Body() loginDto: LoginDto) {}
}

## ORM
- Prisma 사용 (TypeORM 금지)
- schema.prisma에 모든 모델 정의
- Prisma Client는 서비스에서만 직접 접근
- Raw query 금지, Prisma API 활용

## DB
- PostgreSQL 사용

## 환경변수 규칙

### 파일 구조
server/
├── .env              ← 실제 환경변수 (git 제외)
├── .env.example      ← 환경변수 템플릿 (git 포함)
└── src/
    └── config/
        ├── app.config.ts     ← 앱 설정
        ├── jwt.config.ts     ← JWT 설정
        └── nas.config.ts     ← NAS 설정

### 패키지
@nestjs/config, joi 사용

### registerAs 형식 (config 파일별)
// jwt.config.ts
export const jwtConfig = registerAs('jwt', () => ({
  secret: process.env.JWT_SECRET,
  expiresIn: process.env.JWT_EXPIRES_IN || '7d',
}));

// nas.config.ts
export const nasConfig = registerAs('nas', () => ({
  mountPath: process.env.NAS_MOUNT_PATH,
}));

### validationSchema (Joi 필수)
// app.module.ts
ConfigModule.forRoot({
  isGlobal: true,
  load: [appConfig, jwtConfig, nasConfig],
  validationSchema: Joi.object({
    // 서버
    PORT: Joi.number().default(3000),
    NODE_ENV: Joi.string()
      .valid('development', 'production', 'test')
      .default('development'),

    // JWT
    JWT_SECRET: Joi.string().required(),
    JWT_EXPIRES_IN: Joi.string().default('7d'),

    // NAS
    NAS_MOUNT_PATH: Joi.string().required(),
  }),
  validationOptions: {
    abortEarly: true,
  },
});

### 주입 방법
@Injectable()
export class NasService {
  constructor(
    @Inject(nasConfig.KEY)
    private readonly nas: ConfigType<typeof nasConfig>,
  ) {}
}

### .env.example 형식
# 서버 설정
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=your-secret-here
JWT_EXPIRES_IN=7d

# NAS
NAS_MOUNT_PATH=/mnt/nas

### 규칙
- process.env 직접 접근 금지
- 반드시 registerAs로 네임스페이스 분리
- 모든 환경변수는 Joi validationSchema로 검증
- required() 빠뜨리지 말 것
- 새 환경변수 추가 시 .env.example 및 validationSchema 반드시 업데이트
- .env는 절대 커밋 금지