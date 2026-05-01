/// @description 책 상세 StateNotifierProvider 정의
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see BookDetailNotifier
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/storage_providers.dart';
import 'book_detail_notifier.dart';

final bookDetailProvider =
    StateNotifierProvider.autoDispose<BookDetailNotifier, BookDetailState>((ref) {
  final baseUrl = ref.watch(serverBaseUrlProvider);
  final dio = ref.watch(sharedDioProvider);
  return BookDetailNotifier(dio: dio, baseUrl: baseUrl);
});
