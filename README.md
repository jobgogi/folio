# Folio

> PDF · ePub 통합 뷰어 포트폴리오 프로젝트

Flutter 멀티플랫폼 앱과 NestJS 백엔드로 구성된 개인 전자책 뷰어입니다.  
Synology NAS에 저장된 파일을 JWT 인증을 통해 안전하게 불러와 읽을 수 있습니다.

---

## 주요 기능

- **PDF / ePub 뷰어** — 단일 앱에서 두 가지 포맷 통합 지원
- **NAS 연동** — Synology NAS 파일 서버와 연결해 도서 라이브러리 관리
- **JWT 인증** — 로그인 기반 접근 제어
- **멀티플랫폼** — Web · macOS · Android 지원

---

## 기술 스택

### Frontend

| 항목 | 기술 |
|------|------|
| 언어 | Dart |
| 프레임워크 | Flutter (FVM 버전 관리) |
| 상태 관리 | Riverpod |
| HTTP 클라이언트 | Dio |
| PDF 렌더링 | pdfx |
| ePub 렌더링 | epubx |
| 테스트 | flutter_test · mockito |

### Backend

| 항목 | 기술 |
|------|------|
| 언어 | TypeScript |
| 프레임워크 | NestJS |
| 인증 | JWT (@nestjs/jwt) |
| 환경변수 검증 | @nestjs/config · Joi |
| API 문서 | Swagger (@nestjs/swagger) |
| 유효성 검사 | class-validator |
| 테스트 | Jest |

### 인프라

| 항목 | 기술 |
|------|------|
| 배포 | Docker Compose |
| 서버 | Synology NAS |
| 원격 접근 | Tailscale |

---

## 프로젝트 구조

```
folio/
├── app/                        # Flutter 앱
│   ├── lib/
│   │   ├── core/
│   │   │   ├── api/            # Dio 클라이언트 (NasApiClient)
│   │   │   ├── models/         # 공유 모델 (FileModel)
│   │   │   └── detector/       # 파일 타입 감지 (FileDetector)
│   │   ├── features/
│   │   │   ├── library/        # 라이브러리 화면
│   │   │   ├── viewer/         # PDF / ePub 뷰어 화면
│   │   │   ├── settings/       # 설정 화면
│   │   │   └── nas/            # NAS 연결 화면
│   │   └── main.dart
│   └── test/
├── server/                     # NestJS 서버
│   └── src/
│       ├── auth/               # JWT 인증 (POST /v1/auth/login)
│       ├── files/              # 파일 목록 조회 (GET /v1/files)
│       └── config/             # 환경변수 설정 (registerAs · Joi)
└── .claude/                    # AI 협업 규칙 및 워크플로우 문서
```

---

## 개발 방법론

### TDD (테스트 주도 개발)

모든 기능을 Red → Green 순서로 개발합니다.

1. **Red** — 실패하는 테스트 먼저 작성
2. **Green** — 테스트를 통과하는 최소 구현
3. **PR** — feature 브랜치 → develop PR 생성
4. **Review** — 코드 리뷰 후 머지

### Git 브랜치 전략

```
main
 └── develop
      └── feature/phase{N}-{기능명}
```

- `feature/*` → `develop` PR 머지 후 삭제
- `develop` → `main` Phase 완료 시 PR 머지

---

## 시작하기

### 사전 요구사항

- [FVM](https://fvm.app/) (Flutter 버전 관리)
- Node.js 20+
- Docker Compose (서버 배포 시)

### Flutter 앱 실행

```bash
# 의존성 설치
cd app
fvm flutter pub get

# 웹 실행
fvm flutter run -d web

# 테스트
fvm flutter test
```

### NestJS 서버 실행

```bash
cd server

# 환경변수 설정
cp .env.sample .env
# .env 파일에 JWT_SECRET 등 값 입력

# 의존성 설치
npm install

# 개발 서버 실행
npm run start:dev

# 테스트
npm test
```

### API 문서

서버 실행 후 아래 주소에서 Swagger UI 확인 가능합니다.

```
http://localhost:3000/api
```

---

## 라이선스

개인 포트폴리오 프로젝트입니다.
