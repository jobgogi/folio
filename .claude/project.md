# 프로젝트 개요

## 소개
PDF · ePub 통합 뷰어 (포트폴리오 프로젝트)
Flutter 멀티플랫폼 앱 + NestJS 백엔드 + Synology NAS 파일 서버

## 기술 스택
### Frontend (apps/app)
- Flutter (Web · macOS · iOS)
- PDF 렌더링 : pdfx
- ePub 렌더링 : epubx
- 상태 관리  : Riverpod
- HTTP 클라이언트 : Dio

### Backend (apps/server)
- NestJS + TypeScript
- 파일 스트리밍 : NestJS Stream
- 인증 : JWT
- 파일 서버 : Synology NAS

### 인프라
- 배포 : Docker Compose → NAS
- 원격 접근 : Tailscale
- 모노레포 : Melos

## 명령어
### Flutter
melos run test          전체 테스트
melos run build:web     웹 빌드
melos run build:macos   macOS 빌드
flutter test            앱 테스트

### NestJS
npm test                백엔드 테스트
npm run build           빌드
npm run start:dev       개발 서버

### 인프라
docker-compose up -d    NAS 서버 실행

## 디렉토리 구조
apps/
├── app/
│   ├── lib/
│   │   ├── features/
│   │   │   ├── viewer/     # PDF/ePub 뷰어
│   │   │   ├── library/    # 파일 목록
│   │   │   └── auth/       # 인증
│   │   ├── core/
│   │   │   ├── api/        # Dio 클라이언트
│   │   │   └── models/     # 공유 모델
│   │   └── main.dart
│   └── test/
└── server/
    ├── src/
    │   ├── files/          # 파일 스트리밍
    │   ├── auth/           # JWT 인증
    │   └── nas/            # NAS 연동
    └── test/