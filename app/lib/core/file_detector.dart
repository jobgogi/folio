/// @description 파일의 MIME 타입과 확장자를 기반으로 PDF / ePub / unknown 을 감지한다.
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.27
/// @version 1.0.0
/// @see FileModel
enum FileType { pdf, epub, unknown }

class FileDetector {
  /// @description MIME 타입 우선, 확장자 fallback 순으로 파일 타입을 감지한다.
  /// @param mimeType 파일의 MIME 타입
  /// @param fileName 파일명 (확장자 감지용 fallback)
  /// @returns [FileType] pdf / epub / unknown
  FileType detect({required String mimeType, required String fileName}) {
    final normalizedMime = mimeType.toLowerCase();
    if (normalizedMime == 'application/pdf') return FileType.pdf;
    if (normalizedMime == 'application/epub+zip') return FileType.epub;

    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    if (ext == 'pdf') return FileType.pdf;
    if (ext == 'epub') return FileType.epub;

    return FileType.unknown;
  }
}
