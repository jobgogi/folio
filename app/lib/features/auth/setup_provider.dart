/// @description 셋업 StateNotifierProvider 정의
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see SetupNotifier
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/storage_providers.dart';
import 'setup_notifier.dart';

final setupProvider =
    StateNotifierProvider.autoDispose<SetupNotifier, SetupState>((ref) {
  final baseUrl =
      ref.watch(savedServerAddressProvider).valueOrNull ?? '';
  return SetupNotifier(dio: Dio(), baseUrl: baseUrl);
});
