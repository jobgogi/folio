/// @description NAS 파일 서버 통신 클라이언트 추상 인터페이스
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.27
/// @version 1.0.0
/// @see NasApiClient, MockNasClient
import 'package:app/core/file_model.dart';

abstract class NasClient {
  /// @description 경로에 해당하는 파일 목록을 반환한다.
  /// @param path NAS 디렉토리 경로
  /// @returns [List<FileModel>] 파일 목록
  Future<List<FileModel>> getFiles(String path);

  /// @description id에 해당하는 단일 파일 정보를 반환한다.
  /// @param id 파일 고유 식별자
  /// @returns [FileModel?] 파일 정보, 없으면 null
  Future<FileModel?> getFile(String id);
}
