/// @description 설정 화면 — 프로필, 다크모드, 서버 주소, 동기화, 로그아웃
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.05.01
/// @version 1.0.0
/// @see SettingsNotifier, SettingsProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/theme_provider.dart';
import '../../core/widgets/app_button.dart';
import 'settings_notifier.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(settingsProvider.notifier).fetchProfile(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeProvider);

    ref.listen<SettingsState>(settingsProvider, (_, next) {
      if (next is SettingsLoggedOut) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: _buildBody(state, themeMode),
    );
  }

  Widget _buildBody(SettingsState state, ThemeMode themeMode) {
    final profile = ref.read(settingsProvider.notifier).currentProfile;

    return ListView(
      children: [
        _ProfileSection(profile: profile, state: state),
        const Divider(height: 1),
        _AppearanceSection(themeMode: themeMode),
        const Divider(height: 1),
        _SyncSection(state: state),
        const Divider(height: 1),
        const _AccountSection(),
      ],
    );
  }
}

class _ProfileSection extends ConsumerWidget {
  const _ProfileSection({required this.profile, required this.state});
  final SettingsProfile? profile;
  final SettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final username = profile?.username ?? '';
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 36,
                child: Text(
                  initial,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  key: const Key('settings_avatar_change'),
                  onTap: () {},
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              username,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppearanceSection extends ConsumerWidget {
  const _AppearanceSection({required this.themeMode});
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            '화면',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        SwitchListTile(
          key: const Key('settings_dark_mode_toggle'),
          title: const Text('다크 모드'),
          value: themeMode == ThemeMode.dark,
          onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
        ),
        ListTile(
          key: const Key('settings_server_address'),
          title: const Text('서버 주소 변경'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              Navigator.of(context).pushNamed('/server-address'),
        ),
      ],
    );
  }
}

class _SyncSection extends ConsumerWidget {
  const _SyncSection({required this.state});
  final SettingsState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSyncing = state is SettingsSyncing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            '라이브러리',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: AppButton(
            key: const Key('settings_sync_button'),
            label: '동기화',
            isLoading: isSyncing,
            enabled: !isSyncing,
            onPressed: () => ref.read(settingsProvider.notifier).sync(),
          ),
        ),
        if (state is SettingsSynced) _SyncResult(state: state as SettingsSynced),
        if (state is SettingsSyncFailed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              (state as SettingsSyncFailed).message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}

class _SyncResult extends StatelessWidget {
  const _SyncResult({required this.state});
  final SettingsSynced state;

  String _formatTime(DateTime dt) {
    final y = dt.year;
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$y.$mo.$d $h:$mi';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Column(
        key: const Key('settings_sync_result'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatTime(state.lastSyncAt),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Text(
            '추가 ${state.added}  수정 ${state.updated}  삭제 ${state.deleted}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            '계정',
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: AppButton(
            key: const Key('settings_logout_button'),
            label: '로그아웃',
            style: AppButtonStyle.destructive,
            onPressed: () => ref.read(settingsProvider.notifier).logout(),
          ),
        ),
      ],
    );
  }
}
