enum FileType { pdf, epub, unknown }

class FileDetector {
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
