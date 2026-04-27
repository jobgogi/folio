# 프로젝트 개요

## 소개
PDF · ePub 통합 뷰어 (포트폴리오 프로젝트)
Flutter 멀티플랫폼 앱 + NestJS 백엔드 + Synology NAS 파일 서버

## 기술 스택

### Frontend (app/)
- Flutter (Web · macOS · Android)
- Flutter 버전 관리 : FVM
- PDF 렌더링 : pdfx
- ePub 렌더링 : epubx
- 상태 관리 : Riverpod
- HTTP 클라이언트 : Dio

### Backend (server/)
- NestJS + TypeScript
- ORM : Prisma
- DB : PostgreSQL
- 파일 스트리밍 : NestJS Stream
- 인증 : JWT

### 인프라
- 배포 : Docker Compose → NAS
- 원격 접근 : Tailscale

## 명령어

### Flutter
fvm flutter test        테스트 실행
fvm flutter run -d web  웹 실행
fvm flutter build web   웹 빌드
fvm flutter build macos macOS 빌드

### NestJS
npm test                테스트 실행
npm run start:dev       개발 서버
npm run build           빌드

### 인프라
docker-compose up -d    서버 실행

## 화면 목록

### 1. 라이브러리 (메인)
- 책 목록 그리드/리스트
- 최근 읽은 책
- 수동 싱크 버튼

### 2. 뷰어
- PDF / ePub 렌더링 영역
- 상단 툴바 (뒤로가기, 제목, 메뉴)
- 하단 툴바 (페이지 이동, 진행률)
- 북마크 버튼

### 3. 책 상세/수정
- 표지, 제목, 저자, ISBN, 출판사, 출판일
- 메타데이터 수정

### 4. 설정
- NAS 서버 주소 입력
- 인증 정보 (JWT)
- 테마 (라이트/다크)

## 디렉토리 구조
folio/
├── app/                        # Flutter
│   ├── lib/
│   │   ├── features/
│   │   │   ├── library/        # 라이브러리 화면
│   │   │   ├── viewer/         # 뷰어 화면
│   │   │   ├── book/           # 책 상세/수정 화면
│   │   │   └── settings/       # 설정 화면
│   │   ├── core/
│   │   │   ├── api/            # Dio 클라이언트
│   │   │   ├── models/         # 공유 모델
│   │   │   └── detector/       # FileDetector
│   │   └── main.dart
│   └── test/
│       ├── core/
│       └── features/
├── server/                     # NestJS
│   ├── prisma/
│   │   └── schema.prisma       # Book 모델
│   ├── src/
│   │   ├── sync/               # 스캔 + 싱크 (내부 서비스)
│   │   ├── books/              # Book API
│   │   └── auth/               # JWT 인증
│   └── test/
└── .claude/

## API 목록
POST  /v1/sync               수동 싱크 트리거
GET   /v1/books              책 목록 (페이징 + 정렬)
GET   /v1/books/:id          책 상세
PATCH /v1/books/:id          책 메타데이터 수정
PATCH /v1/books/:id/open     열람 시간 갱신
GET   /v1/books/:id/stream   파일 스트리밍 (Phase 3)

## Phase 목록
Phase 1 : Flutter 기반 로직 (완료)
Phase 2 : NestJS + Docker + Prisma + 싱크 + Book API
Phase 3 : JWT 인증 + 파일 스트리밍 API
Phase 4 : Flutter ↔ 서버 연결
Phase 5 : PDF 뷰어
Phase 6 : ePub 뷰어
Phase 7 : 공통 기능 (북마크, 진행률, 다크모드)
Phase 8 : NAS 마운트 + 배포