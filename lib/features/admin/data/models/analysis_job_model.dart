import 'package:equatable/equatable.dart';

class AnalysisJobModel extends Equatable {
  final String id;
  final String journalId;
  final String configurationId;
  final String status;
  final String currentStep;
  final double progress;
  final String? errorMessage;
  final DateTime? startedAt;
  final DateTime? createdAt;
  final String? journalTitle;

  const AnalysisJobModel({
    required this.id,
    required this.journalId,
    required this.configurationId,
    required this.status,
    required this.currentStep,
    required this.progress,
    this.errorMessage,
    this.startedAt,
    this.createdAt,
    this.journalTitle,
  });

  factory AnalysisJobModel.fromJson(Map<String, dynamic> json) {
    final journal = json['journal'] as Map<String, dynamic>?;
    return AnalysisJobModel(
      id: json['id'] as String,
      journalId: json['journal_id'] as String,
      configurationId: json['configuration_id'] as String,
      status: json['status'] as String? ?? 'PENDING',
      currentStep: json['current_step'] as String? ?? 'QUEUED',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      errorMessage: json['error_message'] as String?,
      startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      journalTitle: journal?['title'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, journalId, configurationId, status, currentStep, progress];
}
