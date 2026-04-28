/// @description 책 표지 Widget — 썸네일 또는 기본 아이콘 + 파일 타입 띠지
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see AppColors
import 'package:flutter/material.dart';

import '../file_detector.dart';
import '../theme/app_colors.dart';

class BookCoverWidget extends StatelessWidget {
  const BookCoverWidget({
    super.key,
    required this.thumbnail,
    required this.fileType,
    this.width = 120,
    this.height = 160,
  });

  final String? thumbnail;
  final FileType fileType;
  final double width;
  final double height;

  Color get _badgeColor {
    switch (fileType) {
      case FileType.pdf:
        return AppColors.pdfBadge;
      case FileType.epub:
        return AppColors.epubBadge;
      case FileType.unknown:
        return AppColors.light.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCover(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(
                key: const Key('book_cover_badge'),
                color: _badgeColor,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    fileType.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    if (thumbnail != null) {
      return Image.network(thumbnail!, fit: BoxFit.cover);
    }
    return const ColoredBox(
      color: Color(0xFFE5E5EA),
      child: Center(
        child: Icon(Icons.menu_book, size: 40, color: Color(0xFF8E8E93)),
      ),
    );
  }
}
