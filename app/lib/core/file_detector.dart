enum FileType { pdf, epub, unknown }

class FileDetector {
  FileType detect({required String mimeType, required String fileName}) {
    if (mimeType == 'application/pdf') return FileType.pdf;
    if (mimeType == 'application/epub+zip') return FileType.epub;

    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : '';
    if (ext == 'pdf') return FileType.pdf;
    if (ext == 'epub') return FileType.epub;

    return FileType.unknown;
  }
}
