import 'package:app/core/file_model.dart';

abstract class NasClient {
  Future<List<FileModel>> getFiles(String path);
  Future<FileModel?> getFile(String path);
}
