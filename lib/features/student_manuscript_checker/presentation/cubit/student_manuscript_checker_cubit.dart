import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/check_manuscript_usecase.dart';
import '../../domain/usecases/get_available_journals_usecase.dart';
import 'student_manuscript_checker_state.dart';

class StudentManuscriptCheckerCubit
    extends Cubit<StudentManuscriptCheckerState> {
  final CheckManuscriptUseCase checkManuscriptUseCase;
  final GetAvailableJournalsUseCase? getAvailableJournalsUseCase;

  StudentManuscriptCheckerCubit({
    required this.checkManuscriptUseCase,
    this.getAvailableJournalsUseCase,
  }) : super(const StudentManuscriptCheckerInitial());

  /// Loads available journals from the backend to populate the journal selector.
  Future<void> loadJournals() async {
    final current = state;
    if (current is! StudentManuscriptCheckerInitial) return;

    if (getAvailableJournalsUseCase == null) return;

    emit(current.copyWith(isLoadingJournals: true));
    try {
      final journals = await getAvailableJournalsUseCase!();
      emit(current.copyWith(
        availableJournals: journals,
        isLoadingJournals: false,
        selectedJournalId:
            current.selectedJournalId ?? (journals.isNotEmpty ? journals.first.id : null),
        selectedJournalTitle: current.selectedJournalTitle ??
            (journals.isNotEmpty ? journals.first.title : null),
      ));
    } catch (_) {
      emit(current.copyWith(isLoadingJournals: false));
    }
  }

  void selectJournal(String journalId, String journalTitle) {
    final current = state;
    if (current is StudentManuscriptCheckerInitial) {
      emit(current.copyWith(
        selectedJournalId: journalId,
        selectedJournalTitle: journalTitle,
      ));
    }
  }

  void updateDraftText(String text) {
    final current = state;
    if (current is StudentManuscriptCheckerInitial) {
      emit(current.copyWith(draftText: text));
    }
  }

  void setPickedFile(String name, List<int> bytes) {
    final current = state;
    if (current is StudentManuscriptCheckerInitial) {
      emit(current.copyWith(
        fileName: name,
        fileBytes: bytes,
      ));
    }
  }

  void toggleIncludeExemplars(bool include) {
    final current = state;
    if (current is StudentManuscriptCheckerInitial) {
      emit(current.copyWith(includeExemplars: include));
    }
  }

  /// Submits the manuscript either from direct file bytes or encoded draft text.
  Future<void> submit({
    List<int>? fileBytes,
    String? filename,
    String? targetJournalId,
    bool? includeExemplars,
    String? journalTitle,
  }) async {
    final current = state;
    List<int> bytes = fileBytes ?? const [];
    String name = filename ?? '';
    String journalId = targetJournalId ?? '';
    bool exemplars = includeExemplars ?? true;
    String? title = journalTitle;

    if (current is StudentManuscriptCheckerInitial) {
      if (bytes.isEmpty && current.fileBytes != null && current.fileBytes!.isNotEmpty) {
        bytes = current.fileBytes!;
        name = current.fileName ?? 'manuscript.txt';
      } else if (bytes.isEmpty && current.draftText != null && current.draftText!.trim().isNotEmpty) {
        bytes = utf8.encode(current.draftText!.trim());
        name = 'manuscript.txt';
      }

      if (journalId.isEmpty && current.selectedJournalId != null) {
        journalId = current.selectedJournalId!;
        title ??= current.selectedJournalTitle;
      }

      exemplars = includeExemplars ?? current.includeExemplars;
    }

    if (journalId.trim().isEmpty) {
      emit(const StudentManuscriptCheckerFailure(
        message: 'Please select or enter a target journal ID.',
        statusCode: 400,
      ));
      return;
    }

    if (bytes.isEmpty) {
      emit(const StudentManuscriptCheckerFailure(
        message: 'Please provide manuscript text or select a manuscript file.',
        statusCode: 400,
      ));
      return;
    }

    if (name.isEmpty) {
      name = 'manuscript.txt';
    }

    emit(const StudentManuscriptCheckerLoading());

    try {
      final result = await checkManuscriptUseCase(
        fileBytes: bytes,
        filename: name,
        targetJournalId: journalId.trim(),
        includeExemplars: exemplars,
      );

      if (result.sectionScores.isEmpty &&
          result.warnings.isEmpty &&
          result.suitabilityScore == 0) {
        emit(const StudentManuscriptCheckerEmpty(
          message:
              'The manuscript does not contain any readable sections or recognizable content.',
        ));
      } else {
        emit(StudentManuscriptCheckerSuccess(
          result: result,
          targetJournalId: journalId,
          targetJournalTitle: title,
          manuscriptFileName: name,
          includeExemplars: exemplars,
        ));
      }
    } catch (e) {
      emit(StudentManuscriptCheckerFailure(
        message: _cleanMessage(e),
      ));
    }
  }

  /// Resets state back to initial state, keeping cached available journals.
  void reset() {
    final current = state;
    if (current is StudentManuscriptCheckerSuccess) {
      emit(StudentManuscriptCheckerInitial(
        selectedJournalId: current.targetJournalId,
        selectedJournalTitle: current.targetJournalTitle,
        includeExemplars: current.includeExemplars,
      ));
    } else {
      emit(const StudentManuscriptCheckerInitial());
    }
    loadJournals();
  }

  static String _cleanMessage(Object e) {
    var text = e.toString();
    text = text.replaceFirst(RegExp(r'^[A-Za-z]+Exception: '), '');
    text = text.replaceFirst(RegExp(r' \(code: [^)]*\)'), '');
    return text;
  }
}
