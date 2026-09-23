import 'package:equatable/equatable.dart';

class JournalItemEntity extends Equatable {
  final String id;
  final String title;
  final String category;
  final double impactFactor;
  final int publicationCount;

  const JournalItemEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.impactFactor,
    required this.publicationCount,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    impactFactor,
    publicationCount,
  ];
}
