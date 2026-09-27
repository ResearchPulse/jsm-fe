import 'package:equatable/equatable.dart';

import '../../domain/entities/journal_recommendation_item.dart';
import '../../domain/entities/journal_recommendation_response.dart';

enum JournalRecommendationsStatus { initial, loading, success, failure }

class JournalRecommendationsState extends Equatable {
  final JournalRecommendationsStatus status;
  final JournalRecommendationResponse? recommendationResponse;
  final int availableJournalsCount;
  final String? selectedEvaluationId;
  final String? fileName;
  final List<int>? fileBytes;
  final JournalRecommendationItem? selectedJournalForDetailedView;
  final String? errorMessage;
  final String? pipelineStage;
  final double pipelineProgress;
  final String? pipelineMessage;

  const JournalRecommendationsState({
    this.status = JournalRecommendationsStatus.initial,
    this.recommendationResponse,
    this.availableJournalsCount = 0,
    this.selectedEvaluationId,
    this.fileName,
    this.fileBytes,
    this.selectedJournalForDetailedView,
    this.errorMessage,
    this.pipelineStage,
    this.pipelineProgress = 0.0,
    this.pipelineMessage,
  });

  bool get isInitial => status == JournalRecommendationsStatus.initial;
  bool get isLoading => status == JournalRecommendationsStatus.loading;
  bool get isSuccess => status == JournalRecommendationsStatus.success;
  bool get isFailure => status == JournalRecommendationsStatus.failure;
  bool get hasDetailedView => selectedJournalForDetailedView != null;

  JournalRecommendationsState copyWith({
    JournalRecommendationsStatus? status,
    JournalRecommendationResponse? recommendationResponse,
    int? availableJournalsCount,
    String? selectedEvaluationId,
    bool clearEvaluationId = false,
    String? fileName,
    bool clearFile = false,
    List<int>? fileBytes,
    JournalRecommendationItem? selectedJournalForDetailedView,
    bool clearDetailedView = false,
    String? errorMessage,
    String? pipelineStage,
    double? pipelineProgress,
    String? pipelineMessage,
  }) {
    return JournalRecommendationsState(
      status: status ?? this.status,
      recommendationResponse:
          recommendationResponse ?? this.recommendationResponse,
      availableJournalsCount:
          availableJournalsCount ?? this.availableJournalsCount,
      selectedEvaluationId: clearEvaluationId
          ? null
          : (selectedEvaluationId ?? this.selectedEvaluationId),
      fileName: fileName ?? (clearFile ? null : this.fileName),
      fileBytes: fileBytes ?? (clearFile ? null : this.fileBytes),
      selectedJournalForDetailedView: clearDetailedView
          ? null
          : (selectedJournalForDetailedView ??
                this.selectedJournalForDetailedView),
      errorMessage: errorMessage ?? this.errorMessage,
      pipelineStage: pipelineStage ?? this.pipelineStage,
      pipelineProgress: pipelineProgress ?? this.pipelineProgress,
      pipelineMessage: pipelineMessage ?? this.pipelineMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    recommendationResponse,
    availableJournalsCount,
    selectedEvaluationId,
    fileName,
    fileBytes,
    selectedJournalForDetailedView,
    errorMessage,
    pipelineStage,
    pipelineProgress,
    pipelineMessage,
  ];
}
