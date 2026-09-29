import 'package:equatable/equatable.dart';

import 'manuscript_check_result.dart';

enum PipelineStageType {
  documentPreparation,
  structureExtraction,
  linguisticAnalysis,
  rhetoricalAnalysis,
  journalComparison,
  compatibilityScoring,
  recommendationGeneration,
}

enum PipelineStepStatus { pending, processing, completed, failed }

class PipelineSubTask extends Equatable {
  final String name;
  final PipelineStepStatus status;

  const PipelineSubTask({required this.name, required this.status});

  factory PipelineSubTask.fromMap(Map<String, dynamic> map) {
    final statusStr = (map['status'] as String? ?? 'PENDING').toUpperCase();
    PipelineStepStatus status;
    if (statusStr == 'COMPLETED') {
      status = PipelineStepStatus.completed;
    } else if (statusStr == 'PROCESSING') {
      status = PipelineStepStatus.processing;
    } else if (statusStr == 'FAILED') {
      status = PipelineStepStatus.failed;
    } else {
      status = PipelineStepStatus.pending;
    }

    return PipelineSubTask(name: map['name'] as String? ?? '', status: status);
  }

  PipelineSubTask copyWith({String? name, PipelineStepStatus? status}) {
    return PipelineSubTask(
      name: name ?? this.name,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [name, status];
}

class PipelineStepState extends Equatable {
  final PipelineStageType type;
  final int stepNumber;
  final String title;
  final PipelineStepStatus status;
  final String? activeMessage;
  final String? completionDetail;
  final List<PipelineSubTask> subtasks;

  const PipelineStepState({
    required this.type,
    required this.stepNumber,
    required this.title,
    required this.status,
    this.activeMessage,
    this.completionDetail,
    this.subtasks = const [],
  });

  PipelineStepState copyWith({
    PipelineStageType? type,
    int? stepNumber,
    String? title,
    PipelineStepStatus? status,
    String? activeMessage,
    String? completionDetail,
    List<PipelineSubTask>? subtasks,
  }) {
    return PipelineStepState(
      type: type ?? this.type,
      stepNumber: stepNumber ?? this.stepNumber,
      title: title ?? this.title,
      status: status ?? this.status,
      activeMessage: activeMessage ?? this.activeMessage,
      completionDetail: completionDetail ?? this.completionDetail,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  @override
  List<Object?> get props => [
    type,
    stepNumber,
    title,
    status,
    activeMessage,
    completionDetail,
    subtasks,
  ];
}

class AnalysisPipelineProgress extends Equatable {
  final int currentStepIndex; // 1 to 7
  final int totalSteps; // 7
  final int overallProgress; // 0 to 100
  final String currentMessage;
  final List<PipelineStepState> steps;
  final bool isCompleted;
  final bool isFailed;
  final String? failedStepTitle;
  final String? failureMessage;
  final ManuscriptCheckResult? result;

  const AnalysisPipelineProgress({
    required this.currentStepIndex,
    this.totalSteps = 7,
    required this.overallProgress,
    required this.currentMessage,
    required this.steps,
    this.isCompleted = false,
    this.isFailed = false,
    this.failedStepTitle,
    this.failureMessage,
    this.result,
  });

  factory AnalysisPipelineProgress.initial() {
    return const AnalysisPipelineProgress(
      currentStepIndex: 1,
      totalSteps: 7,
      overallProgress: 5,
      currentMessage: 'Preparing manuscript and establishing connection...',
      steps: [
        PipelineStepState(
          type: PipelineStageType.documentPreparation,
          stepNumber: 1,
          title: 'Preparing Manuscript',
          status: PipelineStepStatus.processing,
          activeMessage: 'Reading manuscript and decoding content...',
        ),
        PipelineStepState(
          type: PipelineStageType.structureExtraction,
          stepNumber: 2,
          title: 'Extracting Document Structure',
          status: PipelineStepStatus.pending,
        ),
        PipelineStepState(
          type: PipelineStageType.linguisticAnalysis,
          stepNumber: 3,
          title: 'Analyzing Linguistic Features',
          status: PipelineStepStatus.pending,
          subtasks: [
            PipelineSubTask(
              name: 'Sentence length',
              status: PipelineStepStatus.pending,
            ),
            PipelineSubTask(
              name: 'Passive voice',
              status: PipelineStepStatus.pending,
            ),
            PipelineSubTask(
              name: 'Author voice',
              status: PipelineStepStatus.pending,
            ),
            PipelineSubTask(
              name: 'Epistemic markers',
              status: PipelineStepStatus.pending,
            ),
          ],
        ),
        PipelineStepState(
          type: PipelineStageType.rhetoricalAnalysis,
          stepNumber: 4,
          title: 'Analyzing Rhetorical Moves',
          status: PipelineStepStatus.pending,
          subtasks: [
            PipelineSubTask(
              name: 'Problem Framing',
              status: PipelineStepStatus.pending,
            ),
            PipelineSubTask(
              name: 'Research Gap',
              status: PipelineStepStatus.pending,
            ),
            PipelineSubTask(
              name: 'Methodology',
              status: PipelineStepStatus.pending,
            ),
          ],
        ),
        PipelineStepState(
          type: PipelineStageType.journalComparison,
          stepNumber: 5,
          title: 'Comparing Journal Style',
          status: PipelineStepStatus.pending,
          subtasks: [
            PipelineSubTask(
              name: 'Section structure',
              status: PipelineStepStatus.pending,
            ),
            PipelineSubTask(
              name: 'Linguistic style',
              status: PipelineStepStatus.pending,
            ),
            PipelineSubTask(
              name: 'Rhetorical profile',
              status: PipelineStepStatus.pending,
            ),
          ],
        ),
        PipelineStepState(
          type: PipelineStageType.compatibilityScoring,
          stepNumber: 6,
          title: 'Calculating Compatibility',
          status: PipelineStepStatus.pending,
        ),
        PipelineStepState(
          type: PipelineStageType.recommendationGeneration,
          stepNumber: 7,
          title: 'Generating Recommendations',
          status: PipelineStepStatus.pending,
        ),
      ],
    );
  }

  AnalysisPipelineProgress updateWithEvent(Map<String, dynamic> event) {
    final eventType = event['event'] as String? ?? '';
    final stageStr = event['stage'] as String? ?? '';
    final progressVal = (event['progress'] as num?)?.toInt() ?? overallProgress;
    final message = event['message'] as String? ?? currentMessage;
    final detail = event['detail'] as String?;

    if (eventType == 'analysis.failed') {
      return copyWith(
        isFailed: true,
        failureMessage: message,
        failedStepTitle: _stageNameToTitle(stageStr),
      );
    }

    if (eventType == 'analysis.completed') {
      final resData = event['data'] as Map<String, dynamic>?;
      final parsedResult = resData != null
          ? ManuscriptCheckResult.fromMap(resData)
          : result;

      // Mark all steps as completed
      final updatedSteps = steps.map((s) {
        return s.copyWith(
          status: PipelineStepStatus.completed,
          completionDetail: s.completionDetail ?? 'Completed',
          subtasks: s.subtasks
              .map((st) => st.copyWith(status: PipelineStepStatus.completed))
              .toList(),
        );
      }).toList();

      return copyWith(
        overallProgress: 100,
        currentStepIndex: 7,
        currentMessage: message,
        steps: updatedSteps,
        isCompleted: true,
        result: parsedResult,
      );
    }

    final targetType = _mapStageStrToType(stageStr);
    final isStageCompleted = eventType == 'stage.completed';
    final isStageStarted = eventType == 'stage.started';

    List<PipelineSubTask>? eventSubtasks;
    if (event['subtasks'] is List) {
      eventSubtasks = (event['subtasks'] as List)
          .whereType<Map<String, dynamic>>()
          .map(PipelineSubTask.fromMap)
          .toList();
    }

    int activeIdx = currentStepIndex;

    final updatedSteps = steps.map((step) {
      if (step.type == targetType) {
        if (isStageCompleted) {
          return step.copyWith(
            status: PipelineStepStatus.completed,
            completionDetail: detail ?? message,
            subtasks:
                eventSubtasks ??
                step.subtasks
                    .map(
                      (st) => st.copyWith(status: PipelineStepStatus.completed),
                    )
                    .toList(),
          );
        } else if (isStageStarted) {
          activeIdx = step.stepNumber;
          return step.copyWith(
            status: PipelineStepStatus.processing,
            activeMessage: message,
            subtasks: eventSubtasks ?? step.subtasks,
          );
        }
      }
      return step;
    }).toList();

    return copyWith(
      currentStepIndex: isStageCompleted
          ? (activeIdx < 7 ? activeIdx + 1 : 7)
          : activeIdx,
      overallProgress: progressVal,
      currentMessage: message,
      steps: updatedSteps,
    );
  }

  static PipelineStageType _mapStageStrToType(String stage) {
    switch (stage.toUpperCase()) {
      case 'DOCUMENT_PREPARATION':
        return PipelineStageType.documentPreparation;
      case 'STRUCTURE_EXTRACTION':
        return PipelineStageType.structureExtraction;
      case 'LINGUISTIC_ANALYSIS':
        return PipelineStageType.linguisticAnalysis;
      case 'RHETORICAL_ANALYSIS':
        return PipelineStageType.rhetoricalAnalysis;
      case 'JOURNAL_COMPARISON':
        return PipelineStageType.journalComparison;
      case 'COMPATIBILITY_SCORING':
        return PipelineStageType.compatibilityScoring;
      case 'RECOMMENDATION_GENERATION':
      default:
        return PipelineStageType.recommendationGeneration;
    }
  }

  static String _stageNameToTitle(String stage) {
    switch (stage.toUpperCase()) {
      case 'DOCUMENT_PREPARATION':
        return 'Preparing Manuscript';
      case 'STRUCTURE_EXTRACTION':
        return 'Extracting Document Structure';
      case 'LINGUISTIC_ANALYSIS':
        return 'Analyzing Linguistic Features';
      case 'RHETORICAL_ANALYSIS':
        return 'Analyzing Rhetorical Moves';
      case 'JOURNAL_COMPARISON':
        return 'Comparing Journal Style';
      case 'COMPATIBILITY_SCORING':
        return 'Calculating Compatibility';
      case 'RECOMMENDATION_GENERATION':
        return 'Generating Recommendations';
      default:
        return 'Analysis Pipeline';
    }
  }

  AnalysisPipelineProgress copyWith({
    int? currentStepIndex,
    int? totalSteps,
    int? overallProgress,
    String? currentMessage,
    List<PipelineStepState>? steps,
    bool? isCompleted,
    bool? isFailed,
    String? failedStepTitle,
    String? failureMessage,
    ManuscriptCheckResult? result,
  }) {
    return AnalysisPipelineProgress(
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      totalSteps: totalSteps ?? this.totalSteps,
      overallProgress: overallProgress ?? this.overallProgress,
      currentMessage: currentMessage ?? this.currentMessage,
      steps: steps ?? this.steps,
      isCompleted: isCompleted ?? this.isCompleted,
      isFailed: isFailed ?? this.isFailed,
      failedStepTitle: failedStepTitle ?? this.failedStepTitle,
      failureMessage: failureMessage ?? this.failureMessage,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
    currentStepIndex,
    totalSteps,
    overallProgress,
    currentMessage,
    steps,
    isCompleted,
    isFailed,
    failedStepTitle,
    failureMessage,
    result,
  ];
}
