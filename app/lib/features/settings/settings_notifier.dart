/// @description 설정 화면 프로필 조회, 동기화, 로그아웃 StateNotifier
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.05.01
/// @version 1.0.0
/// @see SettingsProvider
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsProfile {
  const SettingsProfile({required this.username, this.avatar});
  final String username;
  final String? avatar;
}

sealed class SettingsState {
  const SettingsState();
}

class SettingsIdle extends SettingsState {
  const SettingsIdle();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsLoaded extends SettingsState {
  const SettingsLoaded(this.profile);
  final SettingsProfile profile;
}

class SettingsSyncing extends SettingsState {
  const SettingsSyncing(this.profile);
  final SettingsProfile profile;
}

class SettingsSynced extends SettingsState {
  const SettingsSynced({
    required this.profile,
    required this.lastSyncAt,
    required this.added,
    required this.updated,
    required this.deleted,
  });
  final SettingsProfile profile;
  final DateTime lastSyncAt;
  final int added;
  final int updated;
  final int deleted;
}

class SettingsSyncFailed extends SettingsState {
  const SettingsSyncFailed({required this.profile, required this.message});
  final SettingsProfile profile;
  final String message;
}

class SettingsLoggedOut extends SettingsState {
  const SettingsLoggedOut();
}

class SettingsFailure extends SettingsState {
  const SettingsFailure(this.message);
  final String message;
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier({required Dio dio, required String baseUrl})
      : _dio = dio,
        _baseUrl = baseUrl.replaceAll(RegExp(r'/+$'), ''),
        super(const SettingsIdle());

  final Dio _dio;
  final String _baseUrl;

  /// @description GET /v1/auth/me 호출로 사용자 프로필을 불러온다.
  /// @returns void
  Future<void> fetchProfile() async {
    state = const SettingsLoading();
    try {
      final res = await _dio.get('$_baseUrl/v1/auth/me');
      final data = res.data as Map<String, dynamic>;
      state = SettingsLoaded(
        SettingsProfile(
          username: data['username'] as String,
          avatar: data['avatar'] as String?,
        ),
      );
    } on DioException {
      state = const SettingsFailure('프로필을 불러오는데 실패했습니다.');
    }
  }

  /// @description POST /v1/sync 호출로 라이브러리를 동기화한다.
  /// @returns void
  Future<void> sync() async {
    final profile = currentProfile;
    if (profile == null) return;

    state = SettingsSyncing(profile);
    try {
      final res = await _dio.post('$_baseUrl/v1/sync');
      final data = res.data as Map<String, dynamic>;
      // 서버가 syncAt 필드를 내려주면 해당 값으로 교체할 것
      state = SettingsSynced(
        profile: profile,
        lastSyncAt: DateTime.now(),
        added: (data['added'] as int?) ?? 0,
        updated: (data['updated'] as int?) ?? 0,
        deleted: (data['deleted'] as int?) ?? 0,
      );
    } on DioException {
      state = SettingsSyncFailed(
        profile: profile,
        message: '동기화에 실패했습니다.',
      );
    }
  }

  /// @description 로그아웃 처리한다.
  /// @returns void
  void logout() {
    state = const SettingsLoggedOut();
  }

  /// @description 현재 상태에서 프로필을 추출한다. 프로필이 없는 상태이면 null을 반환한다.
  /// @returns [SettingsProfile?] 현재 프로필, 없으면 null
  SettingsProfile? get currentProfile {
    final s = state;
    if (s is SettingsLoaded) return s.profile;
    if (s is SettingsSyncing) return s.profile;
    if (s is SettingsSynced) return s.profile;
    if (s is SettingsSyncFailed) return s.profile;
    return null;
  }
}
