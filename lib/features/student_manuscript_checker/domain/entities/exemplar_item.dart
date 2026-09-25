import 'package:equatable/equatable.dart';

/// Represents a published sentence exemplar validated from the target journal corpus.
class ExemplarItem extends Equatable {
  final String text;
  final String? articleTitle;
  final String? doi;

  const ExemplarItem({
    required this.text,
    this.articleTitle,
    this.doi,
  });

  factory ExemplarItem.fromMap(Map<String, dynamic> map) {
    return ExemplarItem(
      text: map['text'] as String? ?? '',
      articleTitle: map['article_title'] as String?,
      doi: map['doi'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'article_title': articleTitle,
      'doi': doi,
    };
  }

  @override
  List<Object?> get props => [text, articleTitle, doi];
}
