/// @description 라이브러리 StateNotifierProvider 정의
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see LibraryNotifier
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/storage_providers.dart';
import 'library_notifier.dart';

final libraryProvider =
    StateNotifierProvider.autoDispose<LibraryNotifier, LibraryState>((ref) {
  final baseUrl =
      ref.watch(savedServerAddressProvider).valueOrNull ?? '';
  return LibraryNotifier(dio: Dio(), baseUrl: baseUrl);
});
