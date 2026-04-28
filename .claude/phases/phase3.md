# Phase 3 — 유저 관리 + JWT 인증 + 다운로드 + 썸네일

## 목표
유저 관리, JWT 인증, API 보호, 파일 다운로드, 썸네일 업로드 기능 제공

## Prisma 모델 추가

model User {
  id        String   @id @default(uuid())
  username  String   @unique @map("username")
  password  String
  role      UserRole @default(USER)
  avatar    String?
  createdAt DateTime @default(now()) @map("created_at")
  updatedAt DateTime @updatedAt      @map("updated_at")

  @@map("users")
}

enum UserRole {
  ROOT
  USER

  @@map("user_role")
}

## 작업 목록

### 1. User 모델 마이그레이션
User 모델 추가 및 마이그레이션

작업:
- schema.prisma User 모델 추가
- 마이그레이션 생성 및 적용

테스트:
- 마이그레이션 정상 적용 확인
- User 테이블 생성 확인

브랜치: feature/phase3-user-model

### 2. 셋업 API
최초 실행 시 root 계정 생성

파일 위치: server/src/auth/

엔드포인트:
- GET  /v1/auth/setup-status   셋업 필요 여부 반환 (인증 불필요)
- POST /v1/auth/setup          root 계정 생성 (인증 불필요, 최초 1회만)

GET /v1/auth/setup-status 응답 형식:
{
  needsSetup: boolean
}

POST /v1/auth/setup DTO:
- username: @IsString @IsNotEmpty
- password: @IsString @IsNotEmpty @MinLength(8)

POST /v1/auth/setup 응답 형식:
{
  accessToken: string,
  expiresIn: string
}

기능:
- DB에 유저 없으면 needsSetup: true 반환
- DB에 유저 있으면 needsSetup: false 반환
- POST /v1/auth/setup은 유저 없을 때만 동작
- 이미 유저 있으면 403 반환
- password bcrypt 해싱 후 저장
- 생성 후 자동 로그인 → 토큰 반환

테스트:
- GET /v1/auth/setup-status 유저 없음 → needsSetup: true 검증
- GET /v1/auth/setup-status 유저 있음 → needsSetup: false 검증
- POST /v1/auth/setup root 계정 생성 → 토큰 반환 검증
- POST /v1/auth/setup 이미 유저 있음 → 403 검증
- POST /v1/auth/setup password 8자 미만 → 400 검증
- POST /v1/auth/setup password bcrypt 해싱 검증

브랜치: feature/phase3-setup

### 3. AuthModule
JWT 기반 인증

파일 위치: server/src/auth/

엔드포인트:
- POST /v1/auth/login   JWT 토큰 발급

DTO:
- LoginDto
  - username: @IsString @IsNotEmpty
  - password: @IsString @IsNotEmpty

응답 형식:
{
  accessToken: string,
  expiresIn: string
}

기능:
- username, password 검증
- bcrypt로 password 비교
- JWT 토큰 발급
- 토큰 만료 처리

테스트:
- POST /v1/auth/login 성공 → 토큰 반환 검증
- POST /v1/auth/login 잘못된 username → 401 검증
- POST /v1/auth/login 잘못된 password → 401 검증
- JWT 가드 토큰 없음 → 401 검증
- JWT 가드 만료된 토큰 → 401 검증
- JWT 가드 유효한 토큰 → 통과 검증

브랜치: feature/phase3-auth

### 4. UserModule
유저 관리 API

파일 위치: server/src/users/

엔드포인트:
- POST   /v1/users                   유저 생성 (ROOT만)
- GET    /v1/users                   유저 목록 (ROOT만)
- DELETE /v1/users/:id               유저 삭제 (ROOT만)
- PATCH  /v1/users/:id/password      비밀번호 변경 (본인 또는 ROOT)
- POST   /v1/users/:id/avatar        프로필 사진 업로드 (본인 또는 ROOT)
- GET    /v1/users/:id/avatar        프로필 사진 다운로드 (인증 필요)

DTO:
- CreateUserDto
  - username: @IsString @IsNotEmpty
  - password: @IsString @IsNotEmpty @MinLength(8)
  - role: @IsEnum(UserRole) @IsOptional

- UpdatePasswordDto
  - password: @IsString @IsNotEmpty @MinLength(8)

저장 경로:
- /mnt/nas/.avatars/{userId}.{ext}

프로필 사진 제한:
- 허용 확장자 : jpg, png, webp
- 최대 파일 크기 : 2MB

기능:
- ROOT 권한 가드 적용 (생성/목록/삭제)
- password bcrypt 해싱
- 본인 계정 삭제 불가
- ROOT 계정 삭제 불가
- 프로필 사진 업로드 시 기존 사진 덮어쓰기

테스트:
- POST /v1/users ROOT → 유저 생성 검증
- POST /v1/users USER → 403 검증
- POST /v1/users 중복 username → 409 검증
- GET /v1/users ROOT → 목록 반환 검증
- GET /v1/users USER → 403 검증
- DELETE /v1/users/:id ROOT → 삭제 검증
- DELETE /v1/users/:id 본인 계정 → 400 검증
- DELETE /v1/users/:id ROOT 계정 → 400 검증
- PATCH /v1/users/:id/password 본인 → 변경 검증
- PATCH /v1/users/:id/password ROOT → 변경 검증
- PATCH /v1/users/:id/password 8자 미만 → 400 검증
- POST /v1/users/:id/avatar jpg 업로드 → 저장 후 avatar 경로 반영 검증
- POST /v1/users/:id/avatar png 업로드 → 저장 후 avatar 경로 반영 검증
- POST /v1/users/:id/avatar 허용되지 않는 확장자 → 400 검증
- POST /v1/users/:id/avatar 2MB 초과 → 400 검증
- POST /v1/users/:id/avatar 기존 사진 덮어쓰기 검증
- GET /v1/users/:id/avatar 다운로드 검증
- GET /v1/users/:id/avatar 사진 없음 → 404 검증
- GET /v1/users/:id/avatar 존재하지 않는 id → 404 검증

브랜치: feature/phase3-users

### 5. 기존 API JWT 가드 적용
Phase 2에서 만든 모든 API에 JWT 가드 적용

대상:
- POST  /v1/sync
- GET   /v1/books
- GET   /v1/books/:id
- PATCH /v1/books/:id
- PATCH /v1/books/:id/open

테스트:
- 각 엔드포인트 토큰 없음 → 401 검증
- 각 엔드포인트 유효한 토큰 → 정상 응답 검증

브랜치: feature/phase3-auth-guard

### 6. 파일 다운로드 API
책 파일을 Flutter 앱으로 전달

파일 위치: server/src/books/

엔드포인트:
- GET /v1/books/:id/download

기능:
- NAS 마운트 경로에서 파일 읽기
- Content-Disposition: attachment 헤더 설정
- 파일 타입에 맞는 Content-Type 설정
  - PDF  → application/pdf
  - ePub → application/epub+zip
- 파일 없음 → 404 반환

테스트:
- PDF 파일 다운로드 검증
- ePub 파일 다운로드 검증
- Content-Disposition 헤더 검증
- Content-Type 헤더 검증
- 존재하지 않는 id → 404 검증
- 마운트 경로에 파일 없음 → 404 검증

브랜치: feature/phase3-download

### 7. 썸네일 업로드 API
사용자가 직접 썸네일 이미지 업로드

파일 위치: server/src/books/

엔드포인트:
- POST /v1/books/:id/thumbnail

기능:
- 이미지 파일 업로드 (jpg, png, webp)
- /mnt/nas/.thumbnails/{bookId}.{ext} 경로에 저장
- Book.thumbnail 필드 업데이트
- 기존 썸네일 있으면 덮어쓰기

제한:
- 허용 확장자 : jpg, png, webp
- 최대 파일 크기 : 5MB

테스트:
- jpg 업로드 → 저장 후 thumbnail 경로 반영 검증
- png 업로드 → 저장 후 thumbnail 경로 반영 검증
- 허용되지 않는 확장자 → 400 검증
- 5MB 초과 → 400 검증
- 존재하지 않는 id → 404 검증
- 기존 썸네일 덮어쓰기 검증

브랜치: feature/phase3-thumbnail-upload

### 8. 썸네일 다운로드 API
저장된 썸네일 이미지 전달

파일 위치: server/src/books/

엔드포인트:
- GET /v1/books/:id/thumbnail

기능:
- 썸네일 파일 읽기
- Content-Type 헤더 설정 (image/jpeg, image/png, image/webp)
- Content-Disposition: attachment 헤더 설정
- 썸네일 없으면 404 반환

테스트:
- 썸네일 다운로드 검증
- Content-Type 헤더 검증
- 썸네일 없음 → 404 검증
- 존재하지 않는 id → 404 검증

브랜치: feature/phase3-thumbnail-download

## 브랜치 목록
feature/phase3-user-model
feature/phase3-setup
feature/phase3-auth
feature/phase3-users
feature/phase3-auth-guard
feature/phase3-download
feature/phase3-thumbnail-upload
feature/phase3-thumbnail-download

## 완료 조건
- [x] User 모델 마이그레이션 정상 적용
- [x] GET /v1/auth/setup-status 동작 확인
- [x] POST /v1/auth/setup root 계정 생성 확인
- [x] POST /v1/auth/login 토큰 발급 확인
- [x] POST /v1/users ROOT 전용 확인
- [x] POST /v1/users/:id/avatar 업로드 확인
- [x] GET /v1/users/:id/avatar 다운로드 확인
- [x] 모든 API JWT 가드 적용 확인
- [x] GET /v1/books/:id/download 파일 다운로드 확인
- [x] POST /v1/books/:id/thumbnail 업로드 후 경로 반영 확인
- [x] GET /v1/books/:id/thumbnail 다운로드 확인
- [x] npm test 전체 통과
- [x] Swagger 문서 전체 확인
- [x] 각 브랜치 PR 머지 완료 (develop 기준)
- [x] develop → main PR 머지 완료

## 다음 Phase
Phase 4 시작 조건: Phase 3 완료 조건 전부 충족