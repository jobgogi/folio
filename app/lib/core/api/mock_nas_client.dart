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

  @override
  Future<List<FileModel>> getFiles(String path) async {
    if (path == '/') return List.unmodifiable(_files);
    if (path == '/pdf') return List.unmodifiable(_files.where((f) => f.type == FileType.pdf));
    if (path == '/epub') return List.unmodifiable(_files.where((f) => f.type == FileType.epub));
    return List.unmodifiable([]);
  }

  @override
  Future<FileModel?> getFile(String id) async {
    try {
      return _files.firstWhere((f) => f.path == id);
    } on StateError {
      return null;
    }
  }
}
