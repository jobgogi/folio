/// @description 공통 Widget 단위 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see AppButton, AppTextField, BookCoverWidget
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/file_detector.dart';
import 'package:app/core/theme/app_colors.dart';
import 'package:app/core/widgets/app_button.dart';
import 'package:app/core/widgets/app_text_field.dart';
import 'package:app/core/widgets/book_cover_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppButton', () {
    testWidgets('Primary 스타일로 렌더링된다', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(
          label: '확인',
          onPressed: () {},
          style: AppButtonStyle.primary,
        )),
      );
      expect(find.text('확인'), findsOneWidget);
    });

    testWidgets('로딩 상태이면 CircularProgressIndicator가 표시된다', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(
          label: '확인',
          onPressed: () {},
          isLoading: true,
        )),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('확인'), findsNothing);
    });

    testWidgets('비활성화 상태이면 탭해도 콜백이 호출되지 않는다', (tester) async {
      var called = false;
      await tester.pumpWidget(
        _wrap(AppButton(
          label: '확인',
          onPressed: () => called = true,
          enabled: false,
        )),
      );
      await tester.tap(find.byType(AppButton));
      expect(called, isFalse);
    });
  });

  group('AppTextField', () {
    testWidgets('에러 상태이면 에러 텍스트가 표시된다', (tester) async {
      await tester.pumpWidget(
        _wrap(AppTextField(
          hint: '입력',
          errorText: '필수 항목입니다.',
        )),
      );
      expect(find.text('필수 항목입니다.'), findsOneWidget);
    });

    testWidgets('패스워드 필드에서 토글 버튼을 누르면 텍스트가 표시된다', (tester) async {
      await tester.pumpWidget(
        _wrap(AppTextField(
          hint: '비밀번호',
          isPassword: true,
        )),
      );

      // 초기 상태 — 텍스트 숨김
      final fieldBefore = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(fieldBefore.obscureText, isTrue);

      // 토글 버튼 탭
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // 토글 후 — 텍스트 표시
      final fieldAfter = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(fieldAfter.obscureText, isFalse);
    });
  });

  group('BookCoverWidget', () {
    testWidgets('thumbnail이 null이면 기본 아이콘이 표시된다', (tester) async {
      await tester.pumpWidget(
        _wrap(BookCoverWidget(
          thumbnail: null,
          fileType: FileType.pdf,
        )),
      );
      expect(find.byIcon(Icons.menu_book), findsOneWidget);
    });

    testWidgets('PDF 타입이면 pdfBadge 색상의 띠지가 표시된다', (tester) async {
      await tester.pumpWidget(
        _wrap(BookCoverWidget(
          thumbnail: null,
          fileType: FileType.pdf,
        )),
      );
      final badge = tester.widget<ColoredBox>(
        find.byKey(const Key('book_cover_badge')),
      );
      expect(badge.color, AppColors.pdfBadge);
    });

    testWidgets('ePub 타입이면 epubBadge 색상의 띠지가 표시된다', (tester) async {
      await tester.pumpWidget(
        _wrap(BookCoverWidget(
          thumbnail: null,
          fileType: FileType.epub,
        )),
      );
      final badge = tester.widget<ColoredBox>(
        find.byKey(const Key('book_cover_badge')),
      );
      expect(badge.color, AppColors.epubBadge);
    });

    testWidgets('unknown 타입이면 라이트 테마 secondary 색상의 띠지가 표시된다', (tester) async {
      await tester.pumpWidget(
        _wrap(BookCoverWidget(
          thumbnail: null,
          fileType: FileType.unknown,
        )),
      );
      final badge = tester.widget<ColoredBox>(
        find.byKey(const Key('book_cover_badge')),
      );
      expect(badge.color, AppColors.light.secondary);
    });
  });
}
