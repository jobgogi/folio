/// @description 앱 텍스트 스타일 — Pretendard 폰트 기반
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see AppTheme
import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle title = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w700,
    fontSize: 20,
  );

  static const TextStyle body = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w400,
    fontSize: 16,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: 'Pretendard',
    fontWeight: FontWeight.w300,
    fontSize: 13,
  );
}
