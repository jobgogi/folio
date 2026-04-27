/// @description Dio 기반 NAS 서버 통신 클라이언트 구현체
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.27
/// @version 1.0.0
/// @see NasClient, MockNasClient
import 'package:dio/dio.dart';
import 'package:app/core/api/nas_client.dart';
import 'package:app/core/file_model.dart';

class NasClientException implements Exception {
  final String message;
  NasClientException(this.message);
}

class NasApiClient implements NasClient {
  NasApiClient({required Dio dio, String? token}) : _dio = dio {
    if (token != null) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['Authorization'] = 'Bearer $token';
            handler.next(options);
          },
        ),
      );
    }
  }

  final Dio _dio;

  bool get hasAuthInterceptor =>
      _dio.interceptors.any((i) => i is InterceptorsWrapper);

  /// @description NAS 서버 연결 상태를 확인한다.
  /// @returns [bool] 연결 성공 여부 (예외 발생 시 false 반환)
  Future<bool> ping() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }

  /// @description 경로에 해당하는 파일 목록을 서버에서 조회한다.
  /// @param path NAS 디렉토리 경로
  /// @returns [List<FileModel>] 파일 목록
  /// @throws [NasClientException] 네트워크 오류 발생 시
  @override
  Future<List<FileModel>> getFiles(String path) async {
    try {
      final response = await _dio.get('/files', queryParameters: {'path': path});
      final data = response.data as List<dynamic>;
      return data.map((e) => FileModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw NasClientException(e.message ?? 'getFiles 실패');
    }
  }

  /// @description id에 해당하는 단일 파일 정보를 서버에서 조회한다.
  /// @param id 파일 고유 식별자
  /// @returns [FileModel?] 파일 정보, 404 응답 시 null
  /// @throws [NasClientException] 네트워크 오류 발생 시
  @override
  Future<FileModel?> getFile(String id) async {
    try {
      final response = await _dio.get('/files/$id');
      return FileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw NasClientException(e.message ?? 'getFile 실패');
    }
  }
}
