/// @description 로컬 파일 캐시 관리자
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see None
import 'dart:io';

import 'package:dio/dio.dart';

enum CacheType {
  book('books'),
  thumbnail('thumbnails');

  const CacheType(this.dirName);
  final String dirName;
}

class CacheManager {
  CacheManager({required String storageDir, required Dio dio})
      : _storageDir = storageDir,
        _dio = dio;

  String _storageDir;
  final Dio _dio;

  /// @description 캐시 파일의 로컬 절대 경로를 반환한다.
  /// @param bookId 책 ID
  /// @param ext 파일 확장자
  /// @param type 캐시 타입 (book / thumbnail)
  /// @returns [String] 로컬 파일 절대 경로
  String localPath({
    required String bookId,
    required String ext,
    required CacheType type,
  }) =>
      '$_storageDir/folio/${type.dirName}/$bookId.$ext';

  /// @description 파일이 캐시에 있으면 로컬 경로를, 없으면 다운로드 후 저장하여 경로를 반환한다.
  /// @param bookId 책 ID
  /// @param ext 파일 확장자
  /// @param type 캐시 타입 (book / thumbnail)
  /// @param downloadUrl 다운로드 URL
  /// @returns [String] 로컬 파일 절대 경로
  /// @throws [DioException] 다운로드 실패 시
  Future<String> resolve({
    required String bookId,
    required String ext,
    required CacheType type,
    required String downloadUrl,
  }) async {
    final path = localPath(bookId: bookId, ext: ext, type: type);
    final file = File(path);
    if (await file.exists()) return path;

    final res = await _dio.get<List<int>>(
      downloadUrl,
      options: Options(responseType: ResponseType.bytes),
    );
    await file.create(recursive: true);
    await file.writeAsBytes(res.data!);
    return path;
  }

  /// @description 저장 기본 경로를 변경한다.
  /// @param path 새 저장 경로
  void setStorageDir(String path) => _storageDir = path;

  /// @description 캐시 파일을 삭제한다.
  /// @param bookId 책 ID
  /// @param ext 파일 확장자
  /// @param type 캐시 타입 (book / thumbnail)
  Future<void> delete({
    required String bookId,
    required String ext,
    required CacheType type,
  }) async {
    final file = File(localPath(bookId: bookId, ext: ext, type: type));
    if (await file.exists()) await file.delete();
  }
}
