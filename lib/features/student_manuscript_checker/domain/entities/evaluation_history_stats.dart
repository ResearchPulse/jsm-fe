import 'package:equatable/equatable.dart';

class EvaluationHistoryStats extends Equatable {
  final int totalEvaluations;
  final int strongMatches;
  final int needRevision;
  final double averageCompatibility;

  const EvaluationHistoryStats({
    this.totalEvaluations = 0,
    this.strongMatches = 0,
    this.needRevision = 0,
    this.averageCompatibility = 0.0,
  });

  factory EvaluationHistoryStats.fromMap(Map<String, dynamic> map) {
    return EvaluationHistoryStats(
      totalEvaluations: (map['total_evaluations'] as num?)?.toInt() ?? 0,
      strongMatches: (map['strong_matches'] as num?)?.toInt() ?? 0,
      needRevision: (map['need_revision'] as num?)?.toInt() ?? 0,
      averageCompatibility: (map['average_compatibility'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
        totalEvaluations,
        strongMatches,
        needRevision,
        averageCompatibility,
      ];
}
