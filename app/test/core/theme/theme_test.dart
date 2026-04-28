/// @description AppColors, AppTheme, ThemeNotifier 단위 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see AppTheme
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/core/theme/theme_provider.dart';

void main() {
  group('AppColors', () {
    group('라이트 모드', () {
      test('background는 #FFFFFF이다', () {
        expect(AppColors.light.background, const Color(0xFFFFFFFF));
      });

      test('surface는 #F2F2F7이다', () {
        expect(AppColors.light.surface, const Color(0xFFF2F2F7));
      });

      test('primary는 #1C1C1E이다', () {
        expect(AppColors.light.primary, const Color(0xFF1C1C1E));
      });

      test('secondary는 #6C6C70이다', () {
        expect(AppColors.light.secondary, const Color(0xFF6C6C70));
      });

      test('accent는 #007AFF이다', () {
        expect(AppColors.light.accent, const Color(0xFF007AFF));
      });
    });

    group('다크 모드', () {
      test('background는 #1C1C1E이다', () {
        expect(AppColors.dark.background, const Color(0xFF1C1C1E));
      });

      test('surface는 #2C2C2E이다', () {
        expect(AppColors.dark.surface, const Color(0xFF2C2C2E));
      });

      test('primary는 #FFFFFF이다', () {
        expect(AppColors.dark.primary, const Color(0xFFFFFFFF));
      });

      test('secondary는 #8E8E93이다', () {
        expect(AppColors.dark.secondary, const Color(0xFF8E8E93));
      });

      test('accent는 #0A84FF이다', () {
        expect(AppColors.dark.accent, const Color(0xFF0A84FF));
      });
    });
  });

  group('AppTheme', () {
    test('라이트 테마의 brightness는 light이다', () {
      expect(AppTheme.light.brightness, Brightness.light);
    });

    test('다크 테마의 brightness는 dark이다', () {
      expect(AppTheme.dark.brightness, Brightness.dark);
    });
  });

  group('ThemeNotifier', () {
    late ThemeNotifier notifier;

    setUp(() {
      notifier = ThemeNotifier();
    });

    test('초기 상태는 ThemeMode.light이다', () {
      expect(notifier.state, ThemeMode.light);
    });

    test('toggle 호출 시 dark 모드로 전환된다', () {
      notifier.toggle();
      expect(notifier.state, ThemeMode.dark);
    });

    test('toggle을 두 번 호출 시 light 모드로 복귀한다', () {
      notifier.toggle();
      notifier.toggle();
      expect(notifier.state, ThemeMode.light);
    });
  });
}
