/// @description 책 목록 조회 및 싱크 StateNotifier
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see BooksController
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'book_model.dart';

enum BookSort {
  recentlyRead('recent_opened'),
  name('name'),
  recentlyAdded('recent_added');

  const BookSort(this.value);
  final String value;
}

sealed class LibraryState {
  const LibraryState();
}

class LibraryIdle extends LibraryState {
  const LibraryIdle();
}

class LibraryLoading extends LibraryState {
  const LibraryLoading();
}

class LibraryLoaded extends LibraryState {
  const LibraryLoaded(this.books, {required this.hasMore});
  final List<BookModel> books;
  final bool hasMore;
}

class LibraryFailure extends LibraryState {
  const LibraryFailure(this.message);
  final String message;
}

class LibraryNotifier extends StateNotifier<LibraryState> {
  LibraryNotifier({required Dio dio, required String baseUrl})
      : _dio = dio,
        _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        super(const LibraryIdle());

  final Dio _dio;
  final String _baseUrl;
  int _currentPage = 1;
  BookSort _currentSort = BookSort.recentlyRead;
  bool _isLoadingMore = false;

  /// @description 책 목록을 첫 페이지부터 조회한다.
  /// @param sort 정렬 옵션
  Future<void> fetch(BookSort sort) async {
    if (_baseUrl.isEmpty) return;
    _currentSort = sort;
    _currentPage = 1;
    state = const LibraryLoading();
    try {
      final res = await _dio.get(
        '$_baseUrl/v1/books',
        queryParameters: {'sort': sort.value, 'page': _currentPage},
      );
      if (!mounted) return;
      final data = res.data as Map<String, dynamic>;
      final books = (data['books'] as List)
          .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList();
      state = LibraryLoaded(books, hasMore: data['hasMore'] as bool);
    } catch (_) {
      if (!mounted) return;
      state = const LibraryFailure('책 목록을 불러오는데 실패했습니다.');
    }
  }

  /// @description 다음 페이지 책 목록을 기존 목록에 추가한다.
  Future<void> loadMore() async {
    if (_baseUrl.isEmpty) return;
    final current = state;
    if (current is! LibraryLoaded || !current.hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    _currentPage++;
    try {
      final res = await _dio.get(
        '$_baseUrl/v1/books',
        queryParameters: {'sort': _currentSort.value, 'page': _currentPage},
      );
      if (!mounted) return;
      final data = res.data as Map<String, dynamic>;
      final newBooks = (data['books'] as List)
          .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList();
      state = LibraryLoaded(
        [...current.books, ...newBooks],
        hasMore: data['hasMore'] as bool,
      );
    } catch (_) {
      if (!mounted) return;
      _currentPage--;
    } finally {
      _isLoadingMore = false;
    }
  }

  /// @description POST /v1/sync를 호출해 NAS 파일 싱크를 트리거한다.
  Future<void> sync() async {
    try {
      await _dio.post('$_baseUrl/v1/sync');
    } on DioException {
      // sync 실패는 무시하고 현재 상태 유지
    }
  }
}
