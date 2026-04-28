# Phase 4 — Flutter ↔ 서버 연결

## 목표
서버 httpOnly 쿠키 인증 적용, Flutter 앱 서버 연결,
화면 흐름 구현, 로컬 캐시 전략 적용

## 작업 목록

### 1. 서버 httpOnly 쿠키 적용
Phase 3 인증 방식을 httpOnly 쿠키로 변경

파일 위치: server/src/auth/

변경 사항:
- POST /v1/auth/login  응답을 httpOnly 쿠키로 변경
- POST /v1/auth/setup  응답을 httpOnly 쿠키로 변경
- POST /v1/auth/logout 쿠키 삭제 추가
- GET  /v1/auth/me     현재 유저 정보 반환 추가
- CORS credentials: true 설정
- Flutter 앱 origin 허용

POST /v1/auth/login 응답 형식:
{
  message: 'ok'
}
(토큰은 httpOnly 쿠키로 설정)

POST /v1/auth/logout 응답 형식:
{
  message: 'ok'
}
(쿠키 삭제)

GET /v1/auth/me 응답 형식:
{
  id: string,
  username: string,
  role: UserRole,
  avatar: string | null
}

테스트:
- POST /v1/auth/login 성공 → httpOnly 쿠키 설정 검증
- POST /v1/auth/login 실패 → 쿠키 없음 검증
- POST /v1/auth/logout → 쿠키 삭제 검증
- GET /v1/auth/me 유효한 쿠키 → 유저 정보 반환 검증
- GET /v1/auth/me 쿠키 없음 → 401 검증
- POST /v1/auth/setup 성공 → httpOnly 쿠키 설정 검증

브랜치: feature/phase4-cookie-auth

### 2. Flutter 패키지 설정
Flutter 앱 서버 연결을 위한 패키지 추가

추가 패키지:
- dio                    HTTP 클라이언트
- dio_cookie_manager     쿠키 관리
- cookie_jar             쿠키 저장
- flutter_secure_storage 서버 주소 저장
- path_provider          로컬 파일 경로
- riverpod               상태 관리

파일 위치: app/lib/core/api/

기능:
- Dio 인스턴스 설정
  - withCredentials: true
  - baseUrl: AppConfig.apiBaseUrl
- 쿠키 자동 관리 (dio_cookie_manager)
- 401 응답 시 로그인 화면으로 리다이렉트
- 네트워크 에러 처리

테스트:
- Dio 인스턴스 설정 검증
- 401 응답 → 로그인 리다이렉트 검증
- 네트워크 에러 처리 검증

브랜치: feature/phase4-dio-setup

### 3. 서버 주소 입력 화면
앱 최초 실행 시 서버 주소 입력

파일 위치: app/lib/features/settings/

화면 구성:
- 서버 주소 입력 필드 (예: http://nas.local:3000)
- 연결 테스트 버튼
- 연결 성공 → 다음 단계로 이동
- 연결 실패 → 에러 메시지 표시

기능:
- 서버 주소 flutter_secure_storage에 저장
- GET /v1/health 로 연결 테스트
- 연결 성공 후 GET /v1/auth/setup-status 확인
  - needsSetup: true  → 셋업 화면
  - needsSetup: false → 로그인 화면

테스트:
- 서버 주소 저장 검증
- 연결 테스트 성공 → 다음 화면 이동 검증
- 연결 테스트 실패 → 에러 메시지 검증
- setup-status true → 셋업 화면 이동 검증
- setup-status false → 로그인 화면 이동 검증

브랜치: feature/phase4-server-address

### 4. 셋업 화면
최초 root 계정 생성

파일 위치: app/lib/features/auth/

화면 구성:
- username 입력 필드
- password 입력 필드
- password 확인 입력 필드
- 계정 생성 버튼

기능:
- POST /v1/auth/setup 호출
- password, password 확인 일치 검증
- password 8자 이상 검증
- 성공 → 자동 로그인 → 라이브러리 화면
- 실패 → 에러 메시지 표시

테스트:
- password 불일치 → 에러 메시지 검증
- password 8자 미만 → 에러 메시지 검증
- 성공 → 라이브러리 화면 이동 검증
- 실패 → 에러 메시지 검증

브랜치: feature/phase4-setup-screen

### 5. 로그인 화면
JWT 쿠키 기반 로그인

파일 위치: app/lib/features/auth/

화면 구성:
- username 입력 필드
- password 입력 필드
- 로그인 버튼

기능:
- POST /v1/auth/login 호출
- 성공 → 라이브러리 화면
- 실패 → 에러 메시지 표시
- 앱 재실행 시 GET /v1/auth/me로 자동 로그인 확인

테스트:
- 로그인 성공 → 라이브러리 화면 이동 검증
- 로그인 실패 → 에러 메시지 검증
- 앱 재실행 → GET /v1/auth/me 성공 → 자동 로그인 검증
- 앱 재실행 → GET /v1/auth/me 실패 → 로그인 화면 검증

브랜치: feature/phase4-login-screen

### 6. 라이브러리 화면
책 목록 조회

파일 위치: app/lib/features/library/

화면 구성:
- 책 목록 그리드
- 정렬 옵션 (최근 읽은 순 / 이름순 / 최근 등록순)
- 수동 싱크 버튼
- 책 썸네일, 제목, 저자 표시
- 책 탭 → 책 상세 화면

기능:
- GET /v1/books 페이징으로 목록 조회
- 정렬 옵션 변경 시 재조회
- POST /v1/sync 싱크 트리거
- 무한 스크롤 페이징
- 썸네일 없으면 기본 이미지 표시

테스트:
- 책 목록 조회 검증
- 정렬 옵션 변경 → 재조회 검증
- 무한 스크롤 → 다음 페이지 로드 검증
- 싱크 버튼 → POST /v1/sync 호출 검증
- 썸네일 없음 → 기본 이미지 표시 검증

브랜치: feature/phase4-library-screen

### 7. 로컬 캐시 전략
다운로드 파일 로컬 저장 및 오프라인 읽기

파일 위치: app/lib/core/cache/

기능:
- 기본 저장 경로: getApplicationDocumentsDirectory
- Android 외부 저장소 지원
- 설정에서 저장 경로 변경 가능
- 파일 존재 여부 확인
  - 있으면 로컬에서 바로 열기
  - 없으면 서버에서 다운로드
- 캐시 파일 관리 (삭제, 용량 확인)

저장 경로 구조:
{storageDir}/folio/books/{bookId}.{ext}
{storageDir}/folio/thumbnails/{bookId}.{ext}

테스트:
- 파일 존재 시 로컬 경로 반환 검증
- 파일 없을 시 다운로드 후 저장 검증
- 저장 경로 변경 검증
- 캐시 삭제 검증

브랜치: feature/phase4-local-cache

## 브랜치 목록
feature/phase4-cookie-auth
feature/phase4-dio-setup
feature/phase4-server-address
feature/phase4-setup-screen
feature/phase4-login-screen
feature/phase4-library-screen
feature/phase4-local-cache

## 완료 조건
- [ ] POST /v1/auth/login httpOnly 쿠키 설정 확인
- [ ] POST /v1/auth/logout 쿠키 삭제 확인
- [ ] GET /v1/auth/me 유저 정보 반환 확인
- [ ] 서버 주소 입력 → 연결 테스트 확인
- [ ] 셋업 화면 → root 계정 생성 확인
- [ ] 로그인 화면 → 자동 로그인 확인
- [ ] 라이브러리 화면 → 책 목록 조회 확인
- [ ] 로컬 캐시 저장 및 오프라인 읽기 확인
- [ ] fvm flutter test 전체 통과
- [ ] 각 브랜치 PR 머지 완료 (develop 기준)
- [ ] develop → main PR 머지 완료

## 다음 Phase
Phase 5 시작 조건: Phase 4 완료 조건 전부 충족