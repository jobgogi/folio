/// @description 서버 주소 StateNotifierProvider 정의
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see ServerAddressNotifier, ServerAddressRepository
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/providers/storage_providers.dart';
import 'server_address_notifier.dart';
import 'server_address_repository.dart';

final serverAddressProvider =
    StateNotifierProvider<ServerAddressNotifier, ServerAddressState>(
  (ref) => ServerAddressNotifier(
    repository: FlutterSecureServerAddressRepository(
      storage: const FlutterSecureStorage(),
    ),
    dio: Dio(),
    onSaved: () => ref.invalidate(savedServerAddressProvider),
  ),
);
