/// @description 앱 진입점 — ProviderScope, AppTheme, 라우팅 설정
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.05.01
/// @version 1.0.0
/// @see AppTheme, ThemeProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/setup_screen.dart';
import 'features/library/library_screen.dart';
import 'features/settings/server_address_screen.dart';
import 'features/settings/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: FolioApp()));
}

class FolioApp extends ConsumerWidget {
  const FolioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    return MaterialApp(
      title: 'folio',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      initialRoute: '/',
      routes: {
        '/': (_) => const ServerAddressScreen(),
        '/setup': (_) => const SetupScreen(),
        '/login': (_) => const LoginScreen(),
        '/library': (_) => const LibraryScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/server-address': (_) => const ServerAddressScreen(),
      },
    );
  }
}
