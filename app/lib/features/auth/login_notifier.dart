/// @description 로그인 및 자동 로그인 StateNotifier
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see AuthController
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class LoginState {
  const LoginState();
}

class LoginIdle extends LoginState {
  const LoginIdle();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginFailure extends LoginState {
  const LoginFailure(this.message);
  final String message;
}

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier({required Dio dio, required String baseUrl})
      : _dio = dio,
        _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        super(const LoginIdle());

  final Dio _dio;
  final String _baseUrl;

  /// @description POST /v1/auth/login 호출 후 로그인 처리한다.
  /// @param username 사용자 이름
  /// @param password 비밀번호
  Future<void> login({
    required String username,
    required String password,
  }) async {
    state = const LoginLoading();
    try {
      await _dio.post(
        '$_baseUrl/v1/auth/login',
        data: {'username': username, 'password': password},
      );
      state = const LoginSuccess();
    } on DioException {
      state = const LoginFailure('로그인에 실패했습니다.');
    }
  }

  /// @description GET /v1/auth/me 호출로 자동 로그인 여부를 확인한다.
  Future<void> checkAutoLogin() async {
    state = const LoginLoading();
    try {
      await _dio.get('$_baseUrl/v1/auth/me');
      state = const LoginSuccess();
    } on DioException {
      state = const LoginIdle();
    }
  }
}
