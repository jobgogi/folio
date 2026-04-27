import 'package:app/core/file_detector.dart';

class FileModel {
  final String id;
  final String name;
  final FileType type;
  final String path;
  final DateTime? lastOpenedAt;

  const FileModel({
    required this.id,
    required this.name,
    required this.type,
    required this.path,
    this.lastOpenedAt,
  });

  factory FileModel.fromJson(Map<String, dynamic> json) {
    return FileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: FileType.values.asNameMap()[json['type']] ?? FileType.unknown,
      path: json['path'] as String,
      lastOpenedAt: json['lastOpenedAt'] != null
          ? DateTime.parse(json['lastOpenedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'path': path,
      'lastOpenedAt': lastOpenedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is FileModel &&
      id == other.id &&
      name == other.name &&
      type == other.type &&
      path == other.path &&
      lastOpenedAt == other.lastOpenedAt;

  @override
  int get hashCode => Object.hash(id, name, type, path, lastOpenedAt);
}
