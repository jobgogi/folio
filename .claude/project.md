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
- 파일 스트리밍 : NestJS Stream
- 인증 : JWT
- 파일 서버 : Synology NAS

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
- 파일 목록 그리드/리스트
- 최근 읽은 책
- 파일 추가 버튼 (NAS 연결 or 로컬)

### 2. 뷰어
- PDF / ePub 렌더링 영역
- 상단 툴바 (뒤로가기, 제목, 메뉴)
- 하단 툴바 (페이지 이동, 진행률)
- 북마크 버튼

### 3. 설정
- NAS 서버 주소 입력
- 인증 정보 (JWT)
- 테마 (라이트/다크)

### 4. NAS 연결
- 서버 주소 입력
- 연결 테스트
- 파일 브라우저 (NAS 디렉토리 탐색)

## 디렉토리 구조
folio/
├── app/                        # Flutter
│   ├── lib/
│   │   ├── features/
│   │   │   ├── library/        # 라이브러리 화면
│   │   │   ├── viewer/         # 뷰어 화면
│   │   │   ├── settings/       # 설정 화면
│   │   │   └── nas/            # NAS 연결 화면
│   │   ├── core/
│   │   │   ├── api/            # Dio 클라이언트
│   │   │   ├── models/         # 공유 모델
│   │   │   └── detector/       # FileDetector
│   │   └── main.dart
│   └── test/
│       ├── core/
│       └── features/
├── server/                     # NestJS
│   ├── src/
│   │   ├── files/              # 파일 스트리밍
│   │   ├── auth/               # JWT 인증
│   │   └── nas/                # NAS 연동
│   └── test/
└── .claude/

## Phase 목록
- Phase 1 : 기반 설정 + FileDetector + FileModel + NasClient + FilesModule + AuthModule ✅ 완료
- Phase 2 : Docker Compose + Prisma + FileScanService + FileSyncService + FilesModule API
- Phase 3 : PDF 뷰어
- Phase 4 : ePub 뷰어
- Phase 5 : 공통 기능 (북마크, 진행률, 다크모드)
- Phase 6 : NAS 연동 + Docker 배포