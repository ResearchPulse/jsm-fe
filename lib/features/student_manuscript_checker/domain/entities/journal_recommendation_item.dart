import 'package:equatable/equatable.dart';

import 'manuscript_check_result.dart';

class RecommendationDimensionScores extends Equatable {
  final double structure;
  final double sentenceStyle;
  final double voiceAndPerson;
  final double epistemicStyle;
  final double rhetoricalMoves;

  const RecommendationDimensionScores({
    required this.structure,
    required this.sentenceStyle,
    required this.voiceAndPerson,
    required this.epistemicStyle,
    required this.rhetoricalMoves,
  });

  factory RecommendationDimensionScores.fromMap(Map<String, dynamic> map) {
    return RecommendationDimensionScores(
      structure: (map['structure'] as num?)?.toDouble() ?? 0.0,
      sentenceStyle: (map['sentence_style'] as num?)?.toDouble() ?? 0.0,
      voiceAndPerson: (map['voice_and_person'] as num?)?.toDouble() ?? 0.0,
      epistemicStyle: (map['epistemic_style'] as num?)?.toDouble() ?? 0.0,
      rhetoricalMoves: (map['rhetorical_moves'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'structure': structure,
      'sentence_style': sentenceStyle,
      'voice_and_person': voiceAndPerson,
      'epistemic_style': epistemicStyle,
      'rhetorical_moves': rhetoricalMoves,
    };
  }

  @override
  List<Object?> get props => [
        structure,
        sentenceStyle,
        voiceAndPerson,
        epistemicStyle,
        rhetoricalMoves,
      ];
}

class JournalRecommendationItem extends Equatable {
  final int rank;
  final String journalId;
  final String journalName;
  final String? issn;
  final String? field;
  final String? publisher;
  final String? homepageUrl;
  final double compatibilityScore;
  final String compatibilityLevel;
  final RecommendationDimensionScores dimensions;
  final String dataCoverage;
  final int paperCount;
  final int comparedDimensionsCount;
  final int totalDimensionsCount;
  final String strongestDimension;
  final String weakestDimension;
  final List<String> strongAlignments;
  final List<String> notableDifferences;
  final ManuscriptCheckResult checkResult;

  const JournalRecommendationItem({
    required this.rank,
    required this.journalId,
    required this.journalName,
    this.issn,
    this.field,
    this.publisher,
    this.homepageUrl,
    required this.compatibilityScore,
    required this.compatibilityLevel,
    required this.dimensions,
    required this.dataCoverage,
    required this.paperCount,
    required this.comparedDimensionsCount,
    required this.totalDimensionsCount,
    required this.strongestDimension,
    required this.weakestDimension,
    required this.strongAlignments,
    required this.notableDifferences,
    required this.checkResult,
  });

  bool get isStrongMatch => compatibilityLevel == 'STRONG_MATCH';
  bool get isModerateMatch => compatibilityLevel == 'MODERATE_MATCH';
  bool get isWeakMatch => compatibilityLevel == 'WEAK_MATCH';

  factory JournalRecommendationItem.fromMap(Map<String, dynamic> map) {
    final rawCheckResult = map['check_result'] as Map<String, dynamic>? ?? {};
    return JournalRecommendationItem(
      rank: (map['rank'] as num?)?.toInt() ?? 1,
      journalId: map['journal_id'] as String? ?? '',
      journalName: map['journal_name'] as String? ?? 'Academic Journal',
      issn: map['issn'] as String?,
      field: map['field'] as String?,
      publisher: map['publisher'] as String?,
      homepageUrl: map['homepage_url'] as String?,
      compatibilityScore: (map['compatibility_score'] as num?)?.toDouble() ?? 0.0,
      compatibilityLevel: map['compatibility_level'] as String? ?? 'MODERATE_MATCH',
      dimensions: RecommendationDimensionScores.fromMap(
        map['dimensions'] as Map<String, dynamic>? ?? {},
      ),
      dataCoverage: map['data_coverage'] as String? ?? 'HIGH',
      paperCount: (map['paper_count'] as num?)?.toInt() ?? 0,
      comparedDimensionsCount: (map['compared_dimensions_count'] as num?)?.toInt() ?? 5,
      totalDimensionsCount: (map['total_dimensions_count'] as num?)?.toInt() ?? 5,
      strongestDimension: map['strongest_dimension'] as String? ?? 'RHETORICAL_MOVES',
      weakestDimension: map['weakest_dimension'] as String? ?? 'VOICE_AND_PERSON',
      strongAlignments: (map['strong_alignments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      notableDifferences: (map['notable_differences'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      checkResult: ManuscriptCheckResult.fromMap(rawCheckResult),
    );
  }

  @override
  List<Object?> get props => [
        rank,
        journalId,
        journalName,
        issn,
        field,
        publisher,
        homepageUrl,
        compatibilityScore,
        compatibilityLevel,
        dimensions,
        dataCoverage,
        paperCount,
        comparedDimensionsCount,
        totalDimensionsCount,
        strongestDimension,
        weakestDimension,
        strongAlignments,
        notableDifferences,
        checkResult,
      ];
}
