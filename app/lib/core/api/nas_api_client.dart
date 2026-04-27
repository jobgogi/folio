import 'package:dio/dio.dart';
import 'package:app/core/api/nas_client.dart';
import 'package:app/core/file_model.dart';

class NasClientException implements Exception {
  final String message;
  NasClientException(this.message);
}

class NasApiClient implements NasClient {
  NasApiClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  Future<bool> ping() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } on DioException {
      return false;
    }
  }

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

  @override
  Future<FileModel?> getFile(String path) async {
    try {
      final response = await _dio.get('/files/$path');
      return FileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw NasClientException(e.message ?? 'getFile 실패');
    }
  }
}
