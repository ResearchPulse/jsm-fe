import 'package:equatable/equatable.dart';

import 'journal_recommendation_item.dart';

class JournalRecommendationResponse extends Equatable {
  final String manuscriptName;
  final int totalWords;
  final int totalSentences;
  final int candidateCount;
  final List<JournalRecommendationItem> recommendations;

  const JournalRecommendationResponse({
    required this.manuscriptName,
    required this.totalWords,
    required this.totalSentences,
    required this.candidateCount,
    required this.recommendations,
  });

  factory JournalRecommendationResponse.fromMap(Map<String, dynamic> map) {
    return JournalRecommendationResponse(
      manuscriptName: map['manuscript_name'] as String? ?? 'manuscript.txt',
      totalWords: (map['total_words'] as num?)?.toInt() ?? 0,
      totalSentences: (map['total_sentences'] as num?)?.toInt() ?? 0,
      candidateCount: (map['candidate_count'] as num?)?.toInt() ?? 0,
      recommendations: (map['recommendations'] as List<dynamic>?)
              ?.map((item) => JournalRecommendationItem.fromMap(
                  item as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  @override
  List<Object?> get props => [
        manuscriptName,
        totalWords,
        totalSentences,
        candidateCount,
        recommendations,
      ];
}
