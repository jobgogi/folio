/// @description 책 상세/수정 화면 Widget 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see BookDetailScreen, BookDetailNotifier
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/book/book_detail_notifier.dart';
import 'package:app/features/book/book_detail_provider.dart';
import 'package:app/features/book/book_detail_screen.dart';
import 'package:app/features/library/book_model.dart';

const _book = BookModel(
  id: '1',
  title: '채식주의자',
  author: '한강',
  thumbnail: null,
);

class _FakeNotifier extends BookDetailNotifier {
  _FakeNotifier() : super(dio: Dio(), baseUrl: 'http://test');

  @override
  Future<void> update({
    required String id,
    required String title,
    required String author,
  }) async {}

  void emit(BookDetailState s) => state = s;
}

class _PopObserver extends NavigatorObserver {
  bool popped = false;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    popped = true;
  }
}

Widget _wrap(
  _FakeNotifier notifier, {
  BookModel book = _book,
  List<NavigatorObserver> observers = const [],
}) =>
    ProviderScope(
      overrides: [
        bookDetailProvider.overrideWith((_) => notifier),
      ],
      child: MaterialApp(
        navigatorObservers: observers,
        routes: {
          '/viewer': (_) => const Scaffold(body: Text('ViewerScreen')),
        },
        home: BookDetailScreen(book: book),
      ),
    );

void main() {
  group('BookDetailScreen', () {
    late _FakeNotifier notifier;

    setUp(() => notifier = _FakeNotifier());

    testWidgets('초기 진입 시 BookModel 데이터가 입력 필드에 채워진다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));

      final titleField = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('book_detail_title')),
          matching: find.byType(EditableText),
        ),
      );
      final authorField = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('book_detail_author')),
          matching: find.byType(EditableText),
        ),
      );

      expect(titleField.controller.text, '채식주의자');
      expect(authorField.controller.text, '한강');
    });

    testWidgets('저장 로딩 상태이면 CircularProgressIndicator가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const BookDetailLoading());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('저장 성공이면 이전 화면으로 복귀한다', (tester) async {
      final observer = _PopObserver();
      await tester.pumpWidget(_wrap(notifier, observers: [observer]));
      notifier.emit(const BookDetailSuccess());
      await tester.pumpAndSettle();

      expect(observer.popped, isTrue);
    });

    testWidgets('저장 실패이면 에러 메시지가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const BookDetailFailure('저장에 실패했습니다.'));
      await tester.pump();

      expect(find.text('저장에 실패했습니다.'), findsOneWidget);
    });

    testWidgets('읽기 시작 버튼 탭 시 뷰어 화면으로 이동한다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));

      await tester.tap(find.text('읽기 시작'));
      await tester.pumpAndSettle();

      expect(find.text('ViewerScreen'), findsOneWidget);
    });
  });
}
