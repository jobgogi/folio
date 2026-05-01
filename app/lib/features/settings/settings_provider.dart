/// @description 설정 화면 StateNotifierProvider 정의
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.05.01
/// @version 1.0.0
/// @see SettingsNotifier
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/storage_providers.dart';
import 'settings_notifier.dart';

final settingsProvider =
    StateNotifierProvider.autoDispose<SettingsNotifier, SettingsState>((ref) {
  final baseUrl = ref.watch(savedServerAddressProvider).valueOrNull ?? '';
  final dio = ref.watch(sharedDioProvider);
  return SettingsNotifier(dio: dio, baseUrl: baseUrl);
});
