/// @description 커스텀 버튼 Widget — Primary / Secondary / Destructive 스타일
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see AppColors
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppButtonStyle { primary, secondary, destructive }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final AppButtonStyle style;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? AppColors.dark : AppColors.light;

    Color backgroundColor;
    Color foregroundColor;

    switch (style) {
      case AppButtonStyle.primary:
        backgroundColor = colors.accent;
        foregroundColor = Colors.white;
      case AppButtonStyle.secondary:
        backgroundColor = colors.surface;
        foregroundColor = colors.primary;
      case AppButtonStyle.destructive:
        backgroundColor = AppColors.pdfBadge;
        foregroundColor = Colors.white;
    }

    return ElevatedButton(
      onPressed: (enabled && !isLoading) ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: backgroundColor.withValues(alpha: 0.4),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}
