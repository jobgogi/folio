/// @description 라이브러리 화면 Widget 테스트
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see LibraryScreen, LibraryNotifier
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/features/library/book_model.dart';
import 'package:app/features/library/library_notifier.dart';
import 'package:app/features/library/library_provider.dart';
import 'package:app/features/library/library_screen.dart';

const _books = [
  BookModel(id: '1', title: '채식주의자', author: '한강', thumbnail: null),
  BookModel(id: '2', title: '82년생 김지영', author: '조남주', thumbnail: null),
];

class _FakeNotifier extends LibraryNotifier {
  _FakeNotifier() : super(dio: Dio(), baseUrl: 'http://test');

  BookSort? lastFetchSort;
  bool loadMoreCalled = false;

  @override
  Future<void> fetch(BookSort sort) async {
    lastFetchSort = sort;
  }

  @override
  Future<void> loadMore() async {
    loadMoreCalled = true;
  }

  @override
  Future<void> sync() async {}

  void emit(LibraryState s) => state = s;
}

Widget _wrap(_FakeNotifier notifier) => ProviderScope(
      overrides: [
        libraryProvider.overrideWith((_) => notifier),
      ],
      child: const MaterialApp(home: LibraryScreen()),
    );

void main() {
  group('LibraryScreen', () {
    late _FakeNotifier notifier;

    setUp(() => notifier = _FakeNotifier());

    testWidgets('책 목록이 로드되면 GridView로 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const LibraryLoaded(_books, hasMore: false));
      await tester.pump();

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text('채식주의자'), findsOneWidget);
      expect(find.text('82년생 김지영'), findsOneWidget);
    });

    testWidgets('리스트 전환 버튼 탭 시 ListView로 변경된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const LibraryLoaded(_books, hasMore: false));
      await tester.pump();

      await tester.tap(find.byKey(const Key('library_toggle_view')));
      await tester.pump();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('정렬 옵션 변경 시 해당 sort로 fetch가 호출된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const LibraryLoaded(_books, hasMore: false));
      await tester.pump();

      await tester.tap(find.byKey(const Key('library_sort_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('이름순'));
      await tester.pump();

      expect(notifier.lastFetchSort, BookSort.name);
    });

    testWidgets('빈 목록이면 AppEmptyView가 표시된다', (tester) async {
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(const LibraryLoaded([], hasMore: false));
      await tester.pump();

      expect(find.byKey(const Key('library_empty')), findsOneWidget);
    });

    testWidgets('스크롤이 끝에 닿으면 loadMore가 호출된다', (tester) async {
      final manyBooks = List.generate(
        20,
        (i) => BookModel(
          id: '$i',
          title: '책 $i',
          author: '저자 $i',
          thumbnail: null,
        ),
      );
      await tester.pumpWidget(_wrap(notifier));
      notifier.emit(LibraryLoaded(manyBooks, hasMore: true));
      await tester.pump();

      await tester.drag(find.byType(GridView), const Offset(0, -10000));
      await tester.pumpAndSettle();

      expect(notifier.loadMoreCalled, isTrue);
    });
  });
}
