# Phase 2 — NestJS 서버 기반 + DB + 싱크 + Book API

## 목표
NestJS 서버 기반 구축, PostgreSQL 연동, NAS 마운트 경로 스캔 후
DB 싱크 및 Book API 제공

## Prisma 모델

model Book {
  id               String            @id @default(uuid())

  // 파일 시스템 정보
  name             String
  type             BookType
  path             String            @unique
  size             Int
  lastSyncAt       DateTime          @map("last_sync_at")

  // 메타데이터
  title            String
  author           String?
  isbn             String?
  publisher        String?
  publishedAt      DateTime?         @map("published_at")
  thumbnail        String?
  readingDirection ReadingDirection? @map("reading_direction")

  // 읽기 상태
  lastOpenedAt     DateTime?         @map("last_opened_at")

  createdAt        DateTime          @default(now()) @map("created_at")
  updatedAt        DateTime          @updatedAt      @map("updated_at")

  @@map("books")
}

enum BookType {
  PDF
  EPUB

  @@map("book_type")
}

enum ReadingDirection {
  LTR
  RTL
  TTB

  @@map("reading_direction")
}

## Prisma 네이밍 규칙
- 모델명 : PascalCase → @@map()으로 snake_case 테이블명 매핑
- 필드명 : camelCase → @map()으로 snake_case 컬럼명 매핑
- 모든 camelCase 필드에 @map() 필수

## 작업 목록

### 1. Docker Compose 설정
로컬 개발 환경용 PostgreSQL + NestJS 컨테이너 구성

파일 위치: docker-compose.yml (루트)

구성:
- postgres
  - image: postgres:16
  - 환경변수: POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
  - 볼륨: postgres_data
  - 포트: 5432

- server
  - build: ./server
  - 환경변수: .env 파일 참조
  - 볼륨: NAS 마운트 경로 바인딩
  - depends_on: postgres
  - 포트: 3000

테스트:
- docker-compose up -d 후 postgres 컨테이너 정상 실행 확인
- NestJS 서버 GET /v1/health 응답 확인

브랜치: feature/phase2-docker-compose

### 2. Prisma 설정
PostgreSQL 연동 및 Book 모델 정의

작업:
- prisma init
- schema.prisma 작성 (Book, BookType, ReadingDirection)
- 초기 마이그레이션 생성 및 적용
- PrismaService 작성 (OnModuleInit, OnModuleDestroy)

테스트:
- PrismaService 연결 테스트
- 마이그레이션 정상 적용 확인

브랜치: feature/phase2-prisma

### 3. BookScanService
NAS 마운트 경로를 재귀 탐색하여 PDF/ePub 파일 목록 반환

파일 위치: server/src/sync/book-scan.service.ts

기능:
- 마운트 경로 재귀 탐색
- PDF / ePub 파일만 필터링
- 파일 메타데이터 수집 (name, path, size, type)

테스트:
- 임시 디렉토리에 더미 파일 생성 후 스캔 검증
- PDF / ePub 외 파일 필터링 검증
- 빈 디렉토리 처리 검증
- 중첩 디렉토리 재귀 탐색 검증

브랜치: feature/phase2-book-scan

### 4. BookMetaExtractService
파일에서 메타데이터 자동 추출

파일 위치: server/src/sync/book-meta-extract.service.ts

기능:
- PDF 내장 메타데이터 추출 (제목, 저자)
- ePub 내장 메타데이터 추출 (제목, 저자, ISBN, 출판사, 출판일)
- ePub OPF에서 page-progression-direction 추출
  - ltr → ReadingDirection.LTR
  - rtl → ReadingDirection.RTL
  - ttb → ReadingDirection.TTB
  - 없으면 → null
- 추출 실패 시 파일명을 title로 fallback

테스트:
- PDF 메타데이터 추출 검증
- ePub 메타데이터 추출 검증
- ePub ltr → ReadingDirection.LTR 검증
- ePub rtl → ReadingDirection.RTL 검증
- ePub ttb → ReadingDirection.TTB 검증
- direction 없는 ePub → null 검증
- 메타데이터 없는 파일 → 파일명 fallback 검증
- 손상된 파일 처리 검증

브랜치: feature/phase2-meta-extract

### 5. BookSyncService
스캔 결과를 DB와 비교하여 추가/업데이트/삭제 처리

파일 위치: server/src/sync/book-sync.service.ts

기능:
- 신규 파일 → Book 생성 (메타데이터 자동 추출)
- 기존 파일 → lastSyncAt 업데이트
- 삭제된 파일 → DB에서 제거
- 싱크 완료 후 결과 요약 반환
  { added: number, updated: number, deleted: number }

테스트:
- 신규 파일 → Book 생성 검증
- 메타데이터 추출 성공 시 Book 필드 반영 검증
- 메타데이터 추출 실패 시 파일명 fallback 검증
- 기존 파일 lastSyncAt 업데이트 검증
- 삭제된 파일 Book 제거 검증
- 빈 마운트 경로 처리 검증

브랜치: feature/phase2-book-sync

### 6. SyncModule API
수동 싱크 트리거 API

파일 위치: server/src/sync/

엔드포인트:
- POST /v1/sync

응답 형식:
{
  added: number,
  updated: number,
  deleted: number
}

테스트:
- POST /v1/sync 싱크 결과 반환 검증

브랜치: feature/phase2-sync-api

### 7. BooksModule API
Book 조회 및 수정 API

파일 위치: server/src/books/

엔드포인트:
- GET   /v1/books?page=1&limit=20&sort=recent_opened
- GET   /v1/books/:id
- PATCH /v1/books/:id
- PATCH /v1/books/:id/open

정렬 옵션 (sort 쿼리 파라미터):
- recent_opened : 최근 읽은 순 (기본값, lastOpenedAt DESC)
- name          : 이름순 (title ASC)
- recent_added  : 최근 등록순 (createdAt DESC)

정렬 검증:
- @IsIn(['recent_opened', 'name', 'recent_added'])
- 잘못된 sort 값 → 400 반환

PATCH /v1/books/:id 수정 가능 필드:
- title
- author
- isbn
- publisher
- publishedAt
- thumbnail
- readingDirection

페이징 응답 형식:
{
  data: Book[],
  meta: {
    total: number,
    page: number,
    limit: number,
    totalPages: number
  }
}

테스트:
- GET /v1/books 페이징 + 정렬 검증
- 잘못된 sort 값 → 400 반환 검증
- GET /v1/books/:id 단일 Book 반환 검증
- GET /v1/books/:id 존재하지 않는 id → 404 검증
- PATCH /v1/books/:id 수정 반영 검증
- PATCH /v1/books/:id 일부 필드만 수정 검증
- PATCH /v1/books/:id readingDirection 수정 검증
- PATCH /v1/books/:id 존재하지 않는 id → 404 검증
- PATCH /v1/books/:id/open lastOpenedAt 갱신 검증
- PATCH /v1/books/:id/open 존재하지 않는 id → 404 검증

브랜치: feature/phase2-books-api

## 브랜치 목록
feature/phase2-docker-compose
feature/phase2-prisma
feature/phase2-book-scan
feature/phase2-meta-extract
feature/phase2-book-sync
feature/phase2-sync-api
feature/phase2-books-api

## 완료 조건
- [x] docker-compose up -d 정상 실행
- [x] Prisma 마이그레이션 정상 적용 (20260427060034_init)
- [x] POST /v1/sync 실행 후 DB 반영 확인 (225개 Book 생성)
- [ ] GET /v1/books Swagger 문서 확인
- [x] GET /v1/books 페이징/정렬 응답 확인
- [x] PATCH /v1/books/:id 수정 반영 확인
- [x] PATCH /v1/books/:id/open lastOpenedAt 갱신 확인
- [x] npm test 전체 통과 (44개)
- [x] 각 브랜치 PR 머지 완료 (develop 기준, PR #12~#19)
- [x] develop → main PR 머지 완료 (PR #20)

## 다음 Phase
Phase 3 시작 조건: Phase 2 완료 조건 전부 충족