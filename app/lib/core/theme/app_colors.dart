/// @description 앱 컬러 팔레트 — 라이트/다크 모드 상수 정의
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see AppTheme
import 'package:flutter/material.dart';

class AppColors {
  const AppColors._({
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.accent,
  });

  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color accent;

  static const Color pdfBadge = Color(0xFFFF3B30);
  static const Color epubBadge = Color(0xFF007AFF);

  static const light = AppColors._(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF2F2F7),
    primary: Color(0xFF1C1C1E),
    secondary: Color(0xFF6C6C70),
    accent: Color(0xFF007AFF),
  );

  static const dark = AppColors._(
    background: Color(0xFF1C1C1E),
    surface: Color(0xFF2C2C2E),
    primary: Color(0xFFFFFFFF),
    secondary: Color(0xFF8E8E93),
    accent: Color(0xFF0A84FF),
  );
}
