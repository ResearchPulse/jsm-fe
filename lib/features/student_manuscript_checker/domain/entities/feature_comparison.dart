import 'package:equatable/equatable.dart';

import 'sentence_length_comparison.dart';
import 'stance_comparison.dart';
import 'voice_person_comparison.dart';

/// Aggregation of feature comparisons between the student manuscript and journal benchmark.
class FeatureComparison extends Equatable {
  final SentenceLengthComparison? sentenceLength;
  final VoicePersonComparison? voiceAndPerson;
  final StanceComparison? stance;
  final Map<String, dynamic> additional;

  const FeatureComparison({
    this.sentenceLength,
    this.voiceAndPerson,
    this.stance,
    this.additional = const {},
  });

  factory FeatureComparison.fromMap(Map<String, dynamic> map) {
    final additionalMap =
        (map['additional'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final stanceMap = additionalMap['stance'] as Map<String, dynamic>?;

    return FeatureComparison(
      sentenceLength: map['sentence_length'] != null &&
              map['sentence_length'] is Map<String, dynamic>
          ? SentenceLengthComparison.fromMap(
              map['sentence_length'] as Map<String, dynamic>)
          : null,
      voiceAndPerson: map['voice_and_person'] != null &&
              map['voice_and_person'] is Map<String, dynamic>
          ? VoicePersonComparison.fromMap(
              map['voice_and_person'] as Map<String, dynamic>)
          : null,
      stance: stanceMap != null ? StanceComparison.fromMap(stanceMap) : null,
      additional: additionalMap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sentence_length': sentenceLength?.toMap(),
      'voice_and_person': voiceAndPerson?.toMap(),
      'additional': {
        ...additional,
        if (stance != null) 'stance': stance!.toMap(),
      },
    };
  }

  @override
  List<Object?> get props => [
        sentenceLength,
        voiceAndPerson,
        stance,
        additional,
      ];
}
