/// @description root 계정 생성 StateNotifier
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see AuthController
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class SetupState {
  const SetupState();
}

class SetupIdle extends SetupState {
  const SetupIdle();
}

class SetupLoading extends SetupState {
  const SetupLoading();
}

class SetupSuccess extends SetupState {
  const SetupSuccess();
}

class SetupFailure extends SetupState {
  const SetupFailure(this.message);
  final String message;
}

class SetupNotifier extends StateNotifier<SetupState> {
  SetupNotifier({required Dio dio, required String baseUrl})
      : _dio = dio,
        _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        super(const SetupIdle());

  final Dio _dio;
  final String _baseUrl;

  /// @description 유효성 검증 후 root 계정을 생성한다.
  /// @param username 사용자 이름
  /// @param password 비밀번호
  /// @param confirmPassword 비밀번호 확인
  Future<void> submit({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    if (password.length < 8) {
      state = const SetupFailure('비밀번호는 8자 이상이어야 합니다.');
      return;
    }
    if (password != confirmPassword) {
      state = const SetupFailure('비밀번호가 일치하지 않습니다.');
      return;
    }
    state = const SetupLoading();
    try {
      await _dio.post(
        '$_baseUrl/v1/auth/setup',
        data: {'username': username, 'password': password},
      );
      if (!mounted) return;
      state = const SetupSuccess();
    } catch (_) {
      if (!mounted) return;
      state = const SetupFailure('계정 생성에 실패했습니다.');
    }
  }
}
