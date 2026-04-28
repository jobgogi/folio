/// @description 라이브러리 화면 — 책 목록 그리드/리스트, 정렬, 무한 스크롤
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see LibraryNotifier, LibraryProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/file_detector.dart';
import '../../core/widgets/app_empty_view.dart';
import '../../core/widgets/app_loading_spinner.dart';
import '../../core/widgets/book_cover_widget.dart';
import 'book_model.dart';
import 'library_notifier.dart';
import 'library_provider.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final _scrollController = ScrollController();
  bool _isGrid = true;
  BookSort _sort = BookSort.recentlyRead;

  static const _sortLabels = {
    BookSort.recentlyRead: '최근 읽은 순',
    BookSort.name: '이름순',
    BookSort.recentlyAdded: '최근 등록순',
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(
      () => ref.read(libraryProvider.notifier).fetch(_sort),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(libraryProvider.notifier).loadMore();
    }
  }

  void _changeSort(BookSort sort) {
    setState(() => _sort = sort);
    ref.read(libraryProvider.notifier).fetch(sort);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('folio'),
        actions: [
          IconButton(
            key: const Key('library_toggle_view'),
            icon: Icon(_isGrid ? Icons.list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
          PopupMenuButton<BookSort>(
            key: const Key('library_sort_button'),
            icon: const Icon(Icons.sort),
            onSelected: _changeSort,
            itemBuilder: (_) => _sortLabels.entries
                .map(
                  (e) => PopupMenuItem(
                    value: e.key,
                    child: Text(e.value),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(LibraryState state) {
    if (state is LibraryLoading) {
      return const AppLoadingSpinner(fullScreen: true);
    }
    if (state is LibraryFailure) {
      return Center(child: Text(state.message));
    }
    if (state is LibraryLoaded) {
      if (state.books.isEmpty) {
        return const AppEmptyView(
          key: Key('library_empty'),
          message: '등록된 책이 없습니다.',
        );
      }
      return _isGrid ? _buildGrid(state.books) : _buildList(state.books);
    }
    return const SizedBox.shrink();
  }

  Widget _buildGrid(List<BookModel> books) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemCount: books.length,
      itemBuilder: (_, i) => _GridItem(book: books[i]),
    );
  }

  Widget _buildList(List<BookModel> books) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: books.length,
      itemBuilder: (_, i) => _ListItem(book: books[i]),
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem({required this.book});
  final BookModel book;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: BookCoverWidget(
            thumbnail: book.thumbnail,
            fileType: FileType.unknown,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          book.author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({required this.book});
  final BookModel book;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BookCoverWidget(
          thumbnail: book.thumbnail,
          fileType: FileType.unknown,
          width: 60,
          height: 80,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
