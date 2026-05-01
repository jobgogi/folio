/// @description 책 상세/수정 화면 — 메타데이터 수정 및 읽기 시작
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see BookDetailNotifier, BookDetailProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/file_detector.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/book_cover_widget.dart';
import '../library/book_model.dart';
import 'book_detail_notifier.dart';
import 'book_detail_provider.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  const BookDetailScreen({super.key, required this.book});

  final BookModel book;

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _authorController = TextEditingController(text: widget.book.author);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookDetailProvider);

    ref.listen<BookDetailState>(bookDetailProvider, (_, next) {
      if (next is BookDetailSuccess) {
        Navigator.of(context).pop();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('책 상세'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: BookCoverWidget(
                thumbnail: widget.book.thumbnail,
                fileType: FileDetector().detect(
                  mimeType: widget.book.mimeType,
                  fileName: widget.book.title,
                ),
                width: 160,
                height: 220,
              ),
            ),
            const SizedBox(height: 32),
            AppTextField(
              key: const Key('book_detail_title'),
              hint: '제목',
              controller: _titleController,
            ),
            const SizedBox(height: 12),
            AppTextField(
              key: const Key('book_detail_author'),
              hint: '저자',
              controller: _authorController,
            ),
            if (state is BookDetailFailure) ...[
              const SizedBox(height: 12),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 24),
            AppButton(
              label: '저장',
              isLoading: state is BookDetailLoading,
              enabled: state is! BookDetailLoading,
              onPressed: () => ref.read(bookDetailProvider.notifier).update(
                    id: widget.book.id,
                    title: _titleController.text.trim(),
                    author: _authorController.text.trim(),
                  ),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: '읽기 시작',
              style: AppButtonStyle.secondary,
              onPressed: () =>
                  Navigator.of(context).pushNamed('/viewer'),
            ),
          ],
        ),
      ),
    );
  }
}
