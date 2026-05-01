/// @description 책 메타데이터 수정 StateNotifier
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see BooksController
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class BookDetailState {
  const BookDetailState();
}

class BookDetailIdle extends BookDetailState {
  const BookDetailIdle();
}

class BookDetailLoading extends BookDetailState {
  const BookDetailLoading();
}

class BookDetailSuccess extends BookDetailState {
  const BookDetailSuccess();
}

class BookDetailFailure extends BookDetailState {
  const BookDetailFailure(this.message);
  final String message;
}

class BookDetailNotifier extends StateNotifier<BookDetailState> {
  BookDetailNotifier({required Dio dio, required String baseUrl})
      : _dio = dio,
        _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        super(const BookDetailIdle());

  final Dio _dio;
  final String _baseUrl;

  /// @description 책 메타데이터를 수정한다.
  /// @param id 책 고유 식별자
  /// @param title 수정할 제목
  /// @param author 수정할 저자
  Future<void> update({
    required String id,
    required String title,
    required String author,
  }) async {
    state = const BookDetailLoading();
    try {
      await _dio.patch(
        '$_baseUrl/v1/books/$id',
        data: {'title': title, 'author': author},
      );
      state = const BookDetailSuccess();
    } on DioException {
      state = const BookDetailFailure('저장에 실패했습니다.');
    }
  }
}
