/// @description NAS에서 가져온 파일 정보를 담는 공통 모델
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.27
/// @version 1.0.0
/// @see FileDetector
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

  /// @description JSON Map으로부터 FileModel을 생성한다.
  /// @param json 서버 응답 JSON Map
  /// @returns [FileModel] 파싱된 파일 모델
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

  /// @description FileModel을 JSON Map으로 직렬화한다.
  /// @returns [Map<String, dynamic>] 직렬화된 JSON Map
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
