import 'package:app/core/api/nas_client.dart';
import 'package:app/core/file_detector.dart';
import 'package:app/core/file_model.dart';

class MockNasClient implements NasClient {
  static const _files = [
    FileModel(
      name: 'sample.pdf',
      path: '/pdf/sample.pdf',
      mimeType: 'application/pdf',
      size: 1024,
      fileType: FileType.pdf,
    ),
    FileModel(
      name: 'document.pdf',
      path: '/pdf/document.pdf',
      mimeType: 'application/pdf',
      size: 2048,
      fileType: FileType.pdf,
    ),
    FileModel(
      name: 'novel.epub',
      path: '/epub/novel.epub',
      mimeType: 'application/epub+zip',
      size: 4096,
      fileType: FileType.epub,
    ),
    FileModel(
      name: 'guide.epub',
      path: '/epub/guide.epub',
      mimeType: 'application/epub+zip',
      size: 3072,
      fileType: FileType.epub,
    ),
  ];

  @override
  Future<List<FileModel>> getFiles(String path) async {
    if (path == '/') return List.unmodifiable(_files);
    if (path == '/pdf') return _files.where((f) => f.fileType == FileType.pdf).toList();
    if (path == '/epub') return _files.where((f) => f.fileType == FileType.epub).toList();
    return [];
  }

  @override
  Future<FileModel?> getFile(String path) async {
    try {
      return _files.firstWhere((f) => f.path == path);
    } on StateError {
      return null;
    }
  }
}
