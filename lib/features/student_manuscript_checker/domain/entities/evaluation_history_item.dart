import 'package:equatable/equatable.dart';

class EvaluationHistoryItem extends Equatable {
  final String id;
  final String fileName;
  final String journalName;
  final double overallScore;
  final String compatibilityLevel;
  final String recommendation;
  final int criticalMismatchCount;
  final String status;
  final DateTime createdAt;

  const EvaluationHistoryItem({
    required this.id,
    required this.fileName,
    required this.journalName,
    required this.overallScore,
    required this.compatibilityLevel,
    required this.recommendation,
    required this.criticalMismatchCount,
    required this.status,
    required this.createdAt,
  });

  factory EvaluationHistoryItem.fromMap(Map<String, dynamic> map) {
    return EvaluationHistoryItem(
      id: map['id']?.toString() ?? '',
      fileName: map['file_name']?.toString() ?? 'manuscript.pdf',
      journalName: map['journal_name']?.toString() ?? 'Target Journal',
      overallScore: (map['overall_score'] as num?)?.toDouble() ?? 0.0,
      compatibilityLevel: map['compatibility_level']?.toString() ?? 'MODERATE_MATCH',
      recommendation: map['recommendation']?.toString() ?? 'REVISION_RECOMMENDED',
      criticalMismatchCount: (map['critical_mismatch_count'] as num?)?.toInt() ?? 0,
      status: map['status']?.toString() ?? 'COMPLETED',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        fileName,
        journalName,
        overallScore,
        compatibilityLevel,
        recommendation,
        criticalMismatchCount,
        status,
        createdAt,
      ];
}
