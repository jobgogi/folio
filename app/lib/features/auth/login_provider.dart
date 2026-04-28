/// @description 로그인 StateNotifierProvider 정의
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see LoginNotifier
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'login_notifier.dart';

final _savedServerAddressProvider = FutureProvider<String>((ref) async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'server_address') ?? '';
});

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  final baseUrl =
      ref.watch(_savedServerAddressProvider).valueOrNull ?? '';
  return LoginNotifier(dio: Dio(), baseUrl: baseUrl);
});
