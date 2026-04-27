/// @description 서버 주소 연결 테스트 및 저장 StateNotifier
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.27
/// @version 1.0.0
/// @see ServerAddressRepository
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'server_address_repository.dart';

enum NextScreen { setup, login }

sealed class ServerAddressState {
  const ServerAddressState();
}

class ServerAddressIdle extends ServerAddressState {
  const ServerAddressIdle();
}

class ServerAddressLoading extends ServerAddressState {
  const ServerAddressLoading();
}

class ServerAddressSuccess extends ServerAddressState {
  const ServerAddressSuccess(this.nextScreen);
  final NextScreen nextScreen;
}

class ServerAddressFailure extends ServerAddressState {
  const ServerAddressFailure(this.message);
  final String message;
}

class ServerAddressNotifier extends StateNotifier<ServerAddressState> {
  ServerAddressNotifier({
    required ServerAddressRepository repository,
    required Dio dio,
  })  : _repository = repository,
        _dio = dio,
        super(const ServerAddressIdle());

  final ServerAddressRepository _repository;
  final Dio _dio;

  /// @description 서버 주소 연결을 테스트하고 성공 시 저장 후 다음 화면을 결정한다.
  /// @param address 서버 주소 (예: http://nas.local:3000)
  Future<void> testAndSave(String address) async {
    final base = address.replaceAll(RegExp(r'/+$'), '');
    state = const ServerAddressLoading();
    try {
      await _dio.get('$base/v1/health');
      await _repository.save(base);
      final statusRes = await _dio.get('$base/v1/auth/setup-status');
      final data = statusRes.data as Map<String, dynamic>;
      final needsSetup = data['needsSetup'] as bool;
      state = ServerAddressSuccess(
        needsSetup ? NextScreen.setup : NextScreen.login,
      );
    } on DioException {
      state = const ServerAddressFailure('서버에 연결할 수 없습니다.');
    }
  }
}
