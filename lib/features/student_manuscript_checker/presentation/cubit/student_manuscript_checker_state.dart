import 'package:equatable/equatable.dart';

import '../../domain/entities/manuscript_check_result.dart';
import '../../domain/entities/target_journal.dart';

abstract class StudentManuscriptCheckerState extends Equatable {
  const StudentManuscriptCheckerState();

  @override
  List<Object?> get props => [];
}

/// Initial state when user is preparing a manuscript submission.
class StudentManuscriptCheckerInitial extends StudentManuscriptCheckerState {
  final List<TargetJournal> availableJournals;
  final String? selectedJournalId;
  final String? selectedJournalTitle;
  final String? draftText;
  final String? fileName;
  final List<int>? fileBytes;
  final bool includeExemplars;
  final bool isLoadingJournals;

  const StudentManuscriptCheckerInitial({
    this.availableJournals = const [],
    this.selectedJournalId,
    this.selectedJournalTitle,
    this.draftText,
    this.fileName,
    this.fileBytes,
    this.includeExemplars = true,
    this.isLoadingJournals = false,
  });

  StudentManuscriptCheckerInitial copyWith({
    List<TargetJournal>? availableJournals,
    String? selectedJournalId,
    String? selectedJournalTitle,
    String? draftText,
    String? fileName,
    List<int>? fileBytes,
    bool? includeExemplars,
    bool? isLoadingJournals,
  }) {
    return StudentManuscriptCheckerInitial(
      availableJournals: availableJournals ?? this.availableJournals,
      selectedJournalId: selectedJournalId ?? this.selectedJournalId,
      selectedJournalTitle:
          selectedJournalTitle ?? this.selectedJournalTitle,
      draftText: draftText ?? this.draftText,
      fileName: fileName ?? this.fileName,
      fileBytes: fileBytes ?? this.fileBytes,
      includeExemplars: includeExemplars ?? this.includeExemplars,
      isLoadingJournals: isLoadingJournals ?? this.isLoadingJournals,
    );
  }

  @override
  List<Object?> get props => [
        availableJournals,
        selectedJournalId,
        selectedJournalTitle,
        draftText,
        fileName,
        fileBytes,
        includeExemplars,
        isLoadingJournals,
      ];
}

/// Checker is analyzing the manuscript with the backend NLP engine.
class StudentManuscriptCheckerLoading extends StudentManuscriptCheckerState {
  final String message;

  const StudentManuscriptCheckerLoading({
    this.message = 'Analyzing manuscript against journal style profile…',
  });

  @override
  List<Object?> get props => [message];
}

/// Checker successfully returned evaluation results.
class StudentManuscriptCheckerSuccess extends StudentManuscriptCheckerState {
  final ManuscriptCheckResult result;
  final String targetJournalId;
  final String? targetJournalTitle;
  final String manuscriptFileName;
  final bool includeExemplars;

  const StudentManuscriptCheckerSuccess({
    required this.result,
    required this.targetJournalId,
    this.targetJournalTitle,
    required this.manuscriptFileName,
    required this.includeExemplars,
  });

  @override
  List<Object?> get props => [
        result,
        targetJournalId,
        targetJournalTitle,
        manuscriptFileName,
        includeExemplars,
      ];
}

/// The analysis completed or returned empty section data.
class StudentManuscriptCheckerEmpty extends StudentManuscriptCheckerState {
  final String message;

  const StudentManuscriptCheckerEmpty({
    this.message = 'The manuscript is empty or contains no readable sections.',
  });

  @override
  List<Object?> get props => [message];
}

/// Evaluation failed due to validation, network, or server rejection.
class StudentManuscriptCheckerFailure extends StudentManuscriptCheckerState {
  final String message;
  final int? statusCode;

  const StudentManuscriptCheckerFailure({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];
}
