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
/// @since 2024.06.01
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