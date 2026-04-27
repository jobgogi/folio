/// @description 서버 없이 테스트용 하드코딩 데이터를 반환하는 NasClient Mock 구현체
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.27
/// @version 1.0.0
/// @see NasClient, NasApiClient
import 'package:app/core/api/nas_client.dart';
import 'package:app/core/file_detector.dart';
import 'package:app/core/file_model.dart';

class MockNasClient implements NasClient {
  MockNasClient({List<FileModel>? files}) : _files = files ?? _defaultFiles;

  final List<FileModel> _files;

  static const _defaultFiles = [
    FileModel(
      id: 'file-001',
      name: 'sample.pdf',
      type: FileType.pdf,
      path: '/pdf/sample.pdf',
    ),
    FileModel(
      id: 'file-002',
      name: 'document.pdf',
      type: FileType.pdf,
      path: '/pdf/document.pdf',
    ),
    FileModel(
      id: 'file-003',
      name: 'novel.epub',
      type: FileType.epub,
      path: '/epub/novel.epub',
    ),
    FileModel(
      id: 'file-004',
      name: 'guide.epub',
      type: FileType.epub,
      path: '/epub/guide.epub',
    ),
  ];

  /// @description 경로별로 파일 목록을 필터링해 반환한다.
  /// @param path NAS 디렉토리 경로 ('/', '/pdf', '/epub')
  /// @returns [List<FileModel>] 불변 파일 목록
  @override
  Future<List<FileModel>> getFiles(String path) async {
    if (path == '/') return List.unmodifiable(_files);
    if (path == '/pdf') return List.unmodifiable(_files.where((f) => f.type == FileType.pdf));
    if (path == '/epub') return List.unmodifiable(_files.where((f) => f.type == FileType.epub));
    return List.unmodifiable([]);
  }

  /// @description path로 단일 파일을 조회한다.
  /// @param id 파일 고유 식별자
  /// @returns [FileModel?] 파일 정보, 없으면 null
  @override
  Future<FileModel?> getFile(String id) async {
    try {
      return _files.firstWhere((f) => f.path == id);
    } on StateError {
      return null;
    }
  }
}
