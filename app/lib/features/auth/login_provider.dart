/// @description 로그인 StateNotifierProvider 정의
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see LoginNotifier
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/storage_providers.dart';
import 'login_notifier.dart';

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, LoginState>((ref) {
  final baseUrl = ref.watch(serverBaseUrlProvider);
  final dio = ref.watch(sharedDioProvider);
  return LoginNotifier(dio: dio, baseUrl: baseUrl);
});
