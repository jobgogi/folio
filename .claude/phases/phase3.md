# Phase 3 — JWT 인증 + 다운로드 + 썸네일 업로드

## 목표
API 인증 보호, 파일 다운로드, 썸네일 업로드 기능 제공

## 작업 목록

### 1. AuthModule
JWT 기반 인증

파일 위치: server/src/auth/

기능:
- POST /v1/auth/login   JWT 토큰 발급
- JWT 가드 (모든 API 보호)
- 토큰 만료 처리

환경변수:
- JWT_SECRET
- JWT_EXPIRES_IN

DTO:
- LoginDto
  - username: @IsString @IsNotEmpty
  - password: @IsString @IsNotEmpty

응답 형식:
{
  accessToken: string,
  expiresIn: string
}

테스트:
- POST /v1/auth/login 성공 → 토큰 반환 검증
- POST /v1/auth/login 잘못된 credentials → 401 검증
- JWT 가드 토큰 없음 → 401 검증
- JWT 가드 만료된 토큰 → 401 검증
- JWT 가드 유효한 토큰 → 통과 검증

브랜치: feature/phase3-auth

### 2. 기존 API JWT 가드 적용
Phase 2에서 만든 모든 API에 JWT 가드 적용

대상:
- POST /v1/sync
- GET   /v1/books
- GET   /v1/books/:id
- PATCH /v1/books/:id
- PATCH /v1/books/:id/open

테스트:
- 각 엔드포인트 토큰 없음 → 401 검증
- 각 엔드포인트 유효한 토큰 → 정상 응답 검증

브랜치: feature/phase3-auth-guard

### 3. 파일 다운로드 API
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

### 4. 썸네일 업로드 API
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

### 5. 썸네일 다운로드 API
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
feature/phase3-auth
feature/phase3-auth-guard
feature/phase3-download
feature/phase3-thumbnail-upload
feature/phase3-thumbnail-download

## 완료 조건
- [ ] POST /v1/auth/login 토큰 발급 확인
- [ ] 모든 API JWT 가드 적용 확인
- [ ] GET /v1/books/:id/download 파일 다운로드 확인
- [ ] POST /v1/books/:id/thumbnail 업로드 후 경로 반영 확인
- [ ] GET /v1/books/:id/thumbnail 다운로드 확인
- [ ] npm test 전체 통과
- [ ] Swagger 문서 전체 확인
- [ ] 각 브랜치 PR 머지 완료 (develop 기준)
- [ ] develop → main PR 머지 완료

## 다음 Phase
Phase 4 시작 조건: Phase 3 완료 조건 전부 충족