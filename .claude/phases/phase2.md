# Phase 2 — NestJS 서버 기반 + DB 설정 + 파일 싱크

## 목표
NestJS 서버 기반 구축, PostgreSQL 연동, NAS 마운트 경로 스캔 후 DB 싱크

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
- NestJS 서버 /v1/health 응답 확인

브랜치: feature/phase2-docker-compose

### 2. Prisma 설정
PostgreSQL 연동 및 파일 모델 정의

파일 위치: server/prisma/schema.prisma

모델:
model File {
  id            String    @id @default(uuid())
  name          String
  type          FileType
  path          String    @unique
  size          Int
  lastOpenedAt  DateTime?
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  lastSyncAt    DateTime
}

enum FileType {
  PDF
  EPUB
}

작업:
- prisma init
- schema.prisma 작성
- 초기 마이그레이션 생성
- PrismaService 작성 (OnModuleInit, OnModuleDestroy)

테스트:
- PrismaService 연결 테스트
- 마이그레이션 정상 적용 확인

브랜치: feature/phase2-prisma

### 3. FileScanService
NAS 마운트 경로를 재귀 탐색하여 PDF/ePub 파일 목록 반환

파일 위치: server/src/files/file-scan.service.ts

기능:
- 마운트 경로 재귀 탐색
- PDF / ePub 파일만 필터링
- 파일 메타데이터 수집 (name, path, size, type)

테스트:
- 임시 디렉토리에 더미 파일 생성 후 스캔 검증
- PDF / ePub 외 파일 필터링 검증
- 빈 디렉토리 처리 검증
- 중첩 디렉토리 재귀 탐색 검증

브랜치: feature/phase2-file-scan

### 4. FileSyncService
스캔 결과를 DB와 비교하여 추가/업데이트/삭제 처리

파일 위치: server/src/files/file-sync.service.ts

기능:
- 신규 파일 → DB 추가
- 기존 파일 → lastSyncAt 업데이트
- 삭제된 파일 → DB에서 제거
- 싱크 완료 후 결과 요약 반환
  { added: number, updated: number, deleted: number }

테스트:
- 신규 파일 추가 검증
- 기존 파일 업데이트 검증
- 삭제된 파일 제거 검증
- 빈 마운트 경로 처리 검증

브랜치: feature/phase2-file-sync

### 5. FilesModule API
파일 목록 조회 API

파일 위치: server/src/files/

엔드포인트:
- GET /v1/files?page=1&limit=20&sort=recent_opened
- GET /v1/files/:id
- POST /v1/files/sync

정렬 옵션 (sort 쿼리 파라미터):
- recent_opened : 최근 읽은 순 (기본값, lastOpenedAt DESC)
- name          : 이름순 (name ASC)
- recent_added  : 최근 등록순 (createdAt DESC)

정렬 검증:
- @IsIn(['recent_opened', 'name', 'recent_added'])
- 잘못된 sort 값 → 400 반환

페이징 응답 형식:
{
  data: File[],
  meta: {
    total: number,
    page: number,
    limit: number,
    totalPages: number
  }
}

테스트:
- 기본 정렬 recent_opened 검증
- name 정렬 검증
- recent_added 정렬 검증
- 잘못된 sort 값 → 400 반환 검증
- page,