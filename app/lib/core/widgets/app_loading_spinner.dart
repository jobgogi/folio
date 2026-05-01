/// @description 로딩 인디케이터 Widget — 전체 화면 / 인라인
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see AppColors
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLoadingSpinner extends StatelessWidget {
  const AppLoadingSpinner({super.key, this.fullScreen = false});

  final bool fullScreen;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    final spinner = CircularProgressIndicator(color: colors.accent);

    if (!fullScreen) return spinner;

    return ColoredBox(
      color: colors.background.withValues(alpha: 0.8),
      child: Center(child: spinner),
    );
  }
}
