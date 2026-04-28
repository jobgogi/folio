/// @description 앱 라이트/다크 ThemeData 정의
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see AppColors
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.light.background,
        colorScheme: ColorScheme.light(
          surface: AppColors.light.surface,
          primary: AppColors.light.accent,
          onPrimary: Colors.white,
          secondary: AppColors.light.secondary,
        ),
        textTheme: const TextTheme(
          titleLarge: AppTextStyles.title,
          bodyMedium: AppTextStyles.body,
          bodySmall: AppTextStyles.caption,
        ),
        fontFamily: 'Pretendard',
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.dark.background,
        colorScheme: ColorScheme.dark(
          surface: AppColors.dark.surface,
          primary: AppColors.dark.accent,
          onPrimary: Colors.white,
          secondary: AppColors.dark.secondary,
        ),
        textTheme: const TextTheme(
          titleLarge: AppTextStyles.title,
          bodyMedium: AppTextStyles.body,
          bodySmall: AppTextStyles.caption,
        ),
        fontFamily: 'Pretendard',
      );
}
