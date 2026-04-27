# Flutter 규칙

## 주석 규칙

### 파일 상단 주석 (필수)
모든 파일 최상단에 작성

/// @description 파일 역할 설명
/// @author 설석주 (ixymor@gmail.com)
/// @since YYYY.MM.DD
/// @version 1.0.0
/// @see 참고 파일 또는 None

### 함수 주석 (비즈니스 로직 필수)
/// @description 함수 역할 설명
/// @param mimeType 파일의 MIME 타입
/// @param fileName 파일명 (확장자 감지용 fallback)
/// @returns [FileType] pdf / epub / unknown
/// @throws [UnsupportedError] 처리할 수 없는 파일 형식일 때

### 예시 (전체)
/// @description 파일의 MIME 타입과 확장자를 기반으로
/// PDF / ePub / unknown 을 감지한다.
/// @author 설석주 (ixymor@gmail.com)
/// @since YYYY.MM.DD
/// @version 1.0.0
/// @see FileModel
class FileDetector {

  /// @description 파일 타입을 감지한다.
  /// @param mimeType 파일의 MIME 타입
  /// @param fileName 파일명 (확장자 감지용 fallback)
  /// @returns [FileType] pdf / epub / unknown
  FileType detect(String mimeType, String fileName) {}

  /// @description 확장자로 파일 타입을 감지한다.
  /// @param fileName 파일명
  /// @returns [FileType] epub / unknown
  FileType _detectByExtension(String fileName) {}
}

## 상태 관리
- 상태 관리는 Riverpod 사용
- StateNotifier 기반으로 작성
- Provider는 파일 단위로 분리

## 네이밍
- Widget   : PascalCase
- Provider : camelCase + Provider 접미사
  예) fileListProvider, readerStateProvider
- Model    : PascalCase + Model 접미사
  예) FileModel, ReaderStateModel

## 환경변수 규칙

### 파일 구조
app/
├── .env              ← 실제 환경변수 (git 제외)
├── .env.example      ← 환경변수 템플릿 (git 포함)
└── lib/
    └── core/
        └── config/
            └── app_config.dart  ← 환경변수 중앙 관리

### 패키지
flutter_dotenv 사용

### app_config.dart 형식
/// @description 앱 환경변수 중앙 관리
/// @author 설석주 (ixymor@gmail.com)
/// @since YYYY.MM.DD
/// @version 1.0.0
/// @see None
class AppConfig {
  /// @description API 기본 URL
  /// @returns [String] API 서버 주소
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? '';

  /// @description API 버전
  /// @returns [String] API 버전 문자열
  static String get apiVersion =>
      dotenv.env['API_VERSION'] ?? 'v1';

  /// @description 앱 실행 환경
  /// @returns [String] development / production
  static String get appEnv =>
      dotenv.env['APP_ENV'] ?? 'development';
}

### .env.example 형식
# 서버 설정
API_BASE_URL=http://your-server-host:3000
API_VERSION=v1

# 기타
APP_ENV=development

### 규칙
- dotenv.env 직접 접근 금지
- 반드시 AppConfig 통해서 접근
- 새 환경변수 추가 시 .env.example 반드시 업데이트
- .env는 절대 커밋 금지
- main.dart에서 앱 시작 시 dotenv.load() 호출