/// @description 책 데이터 모델
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see LibraryNotifier
class BookModel {
  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    this.thumbnail,
  });

  final String id;
  final String title;
  final String author;
  final String? thumbnail;

  /// @description JSON으로부터 BookModel을 생성한다.
  /// @param json API 응답 Map
  /// @returns [BookModel]
  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        thumbnail: json['thumbnail'] as String?,
      );
}
