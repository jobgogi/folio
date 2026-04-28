/// @description 셋업 StateNotifierProvider 정의
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see SetupNotifier
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'setup_notifier.dart';

final _savedServerAddressProvider = FutureProvider<String>((ref) async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'server_address') ?? '';
});

final setupProvider = StateNotifierProvider<SetupNotifier, SetupState>((ref) {
  final baseUrl =
      ref.watch(_savedServerAddressProvider).valueOrNull ?? '';
  return SetupNotifier(dio: Dio(), baseUrl: baseUrl);
});
