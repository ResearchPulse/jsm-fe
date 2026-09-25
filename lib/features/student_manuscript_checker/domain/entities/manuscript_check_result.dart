import 'package:equatable/equatable.dart';

import 'exemplar_item.dart';
import 'feature_comparison.dart';
import 'warning_item.dart';

/// Overall result of checking a student manuscript against a journal style profile.
class ManuscriptCheckResult extends Equatable {
  final double suitabilityScore;
  final String ratingLevel;
  final String summary;
  final Map<String, double> sectionScores;
  final FeatureComparison featureComparison;
  final List<WarningItem> warnings;

  const ManuscriptCheckResult({
    required this.suitabilityScore,
    required this.ratingLevel,
    required this.summary,
    required this.sectionScores,
    required this.featureComparison,
    this.warnings = const [],
  });

  bool get isExcellent => ratingLevel == 'EXCELLENT_ALIGNMENT';
  bool get isModerate => ratingLevel == 'MODERATE_ALIGNMENT';
  bool get isSignificantDeviation => ratingLevel == 'SIGNIFICANT_DEVIATION';

  String get ratingLabel {
    switch (ratingLevel) {
      case 'EXCELLENT_ALIGNMENT':
        return 'Excellent Alignment';
      case 'MODERATE_ALIGNMENT':
        return 'Moderate Alignment';
      case 'SIGNIFICANT_DEVIATION':
        return 'Significant Deviation';
      default:
        return ratingLevel.replaceAll('_', ' ');
    }
  }

  /// Critical missing research gap warnings
  List<WarningItem> get missingGapWarnings =>
      warnings.where((w) => w.isGapWarning).toList();

  /// All rhetorical move warnings
  List<WarningItem> get rhetoricalMoveWarnings =>
      warnings.where((w) => w.isRhetoricalMoveWarning).toList();

  /// All sentence length warnings
  List<WarningItem> get sentenceLengthWarnings =>
      warnings.where((w) => w.isSentenceLengthWarning).toList();

  /// All voice and person warnings
  List<WarningItem> get voicePersonWarnings =>
      warnings.where((w) => w.isVoicePersonWarning).toList();

  /// All stance warnings
  List<WarningItem> get stanceWarnings =>
      warnings.where((w) => w.isStanceWarning).toList();

  /// Warnings that returned a validated exemplar from the target journal
  List<ExemplarItem> get validatedExemplars =>
      warnings.map((w) => w.exemplar).whereType<ExemplarItem>().toList();

  bool get hasMissingGap => missingGapWarnings.isNotEmpty;
  bool get hasExemplars => validatedExemplars.isNotEmpty;

  factory ManuscriptCheckResult.fromMap(Map<String, dynamic> map) {
    final sectionScoresRaw =
        map['section_scores'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final sectionScores = <String, double>{};
    sectionScoresRaw.forEach((key, value) {
      if (value is num) {
        sectionScores[key] = value.toDouble();
      }
    });

    final warningsListRaw = map['warnings'] as List<dynamic>? ?? [];
    final warnings = warningsListRaw
        .whereType<Map<String, dynamic>>()
        .map(WarningItem.fromMap)
        .toList();

    return ManuscriptCheckResult(
      suitabilityScore: (map['suitability_score'] as num?)?.toDouble() ?? 0.0,
      ratingLevel: map['rating_level'] as String? ?? 'MODERATE_ALIGNMENT',
      summary: map['summary'] as String? ?? '',
      sectionScores: sectionScores,
      featureComparison: map['feature_comparison'] != null &&
              map['feature_comparison'] is Map<String, dynamic>
          ? FeatureComparison.fromMap(
              map['feature_comparison'] as Map<String, dynamic>)
          : const FeatureComparison(),
      warnings: warnings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'suitability_score': suitabilityScore,
      'rating_level': ratingLevel,
      'summary': summary,
      'section_scores': sectionScores,
      'feature_comparison': featureComparison.toMap(),
      'warnings': warnings.map((w) => w.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        suitabilityScore,
        ratingLevel,
        summary,
        sectionScores,
        featureComparison,
        warnings,
      ];
}
