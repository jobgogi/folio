# Phase 1 — 기반 설정

## 목표
프로젝트 뼈대 + 핵심 기반 로직 구축

## 작업 목록

### Flutter (app/)

#### 1. FileDetector
파일 MIME 타입 기반으로 PDF / ePub / unknown 감지

감지 조건:
- application/pdf → FileType.pdf
- application/epub+zip → FileType.epub
- .epub 확장자 (MIME 없을 때) → FileType.epub
- 나머지 → FileType.unknown

테스트 위치: test/core/detector/file_detector_test.dart
구현 위치:   lib/core/detector/file_detector.dart

#### 2. FileModel
파일 정보를 담는 공통 모델

필드:
- id (String)
- name (String)
- type (FileType)
- path (String)
- lastOpenedAt (DateTime?)

테스트 위치: test/core/models/file_model_test.dart
구현 위치:   lib/core/models/file_model.dart

#### 3. NasApiClient 기본 구조
Dio 기반 NAS 서버 통신 클라이언트

기능:
- baseUrl 설정
- JWT 토큰 인터셉터
- 연결 테스트 (ping)
- 에러 핸들링

테스트 위치: test/core/api/nas_api_client_test.dart
구현 위치:   lib/core/api/nas_api_client.dart

### NestJS (server/)

#### 4. FilesModule 기본 구조
NAS 파일 목록 조회 API

엔드포인트:
- GET /files        파일 목록 반환
- GET /files/:id    단일 파일 정보

테스트 위치: test/files/files.service.spec.ts
구현 위치:   src/files/

#### 5. AuthModule 기본 구조
JWT 인증

기능:
- POST /auth/login  토큰 발급
- JWT 가드

테스트 위치: test/auth/auth.service.spec.ts
구현 위치:   src/auth/

## 브랜치 목록
feature/phase1-file-detector
feature/phase1-file-model
feature/phase1-nas-api-client
feature/phase1-files-module
feature/phase1-auth-module

## 완료 조건
- [ ] fvm flutter test 전체 통과
- [ ] npm test 전체 통과
- [ ] 각 브랜치 PR 머지 완료 (develop 기준)
- [ ] develop → main PR 머지 완료

## 다음 Phase
Phase 2 시작 조건: Phase 1 완료 조건 전부 충족