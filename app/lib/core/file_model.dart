import 'package:app/core/file_detector.dart';

class FileModel {
  final String name;
  final String path;
  final String mimeType;
  final int size;
  final FileType fileType;

  const FileModel({
    required this.name,
    required this.path,
    required this.mimeType,
    required this.size,
    required this.fileType,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      name: json['name'] as String,
      path: json['path'] as String,
      mimeType: json['mimeType'] as String,
      size: (json['size'] as num).toInt(),
      fileType: FileType.values.asNameMap()[json['fileType']] ?? FileType.unknown,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'mimeType': mimeType,
      'size': size,
      'fileType': fileType.name,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is FileModel &&
      name == other.name &&
      path == other.path &&
      mimeType == other.mimeType &&
      size == other.size &&
      fileType == other.fileType;

  @override
  int get hashCode => Object.hash(name, path, mimeType, size, fileType);
}
