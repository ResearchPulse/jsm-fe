import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/core/errors/exceptions.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/feature_comparison.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/manuscript_check_result.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/target_journal.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/repositories/student_manuscript_repository.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/usecases/check_manuscript_usecase.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/usecases/get_available_journals_usecase.dart';
import 'package:jsm_fe/features/student_manuscript_checker/presentation/cubit/student_manuscript_checker_cubit.dart';
import 'package:jsm_fe/features/student_manuscript_checker/presentation/cubit/student_manuscript_checker_state.dart';

class _FakeStudentManuscriptRepository implements StudentManuscriptRepository {
  Object? error;
  ManuscriptCheckResult? result;
  List<TargetJournal> journals = const [
    TargetJournal(id: 'j-1', title: 'Target Journal Alpha'),
  ];

  @override
  Future<ManuscriptCheckResult> checkManuscript({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) async {
    if (error != null) throw error!;
    return result ??
        const ManuscriptCheckResult(
          suitabilityScore: 85.0,
          ratingLevel: 'EXCELLENT_ALIGNMENT',
          summary: 'High stylistic alignment.',
          sectionScores: {'INTRO': 90.0},
          featureComparison: FeatureComparison(),
        );
  }

  @override
  Future<List<TargetJournal>> getAvailableJournals() async {
    if (error != null) throw error!;
    return journals;
  }
}

void main() {
  group('StudentManuscriptCheckerCubit', () {
    test('initial state has default configuration', () {
      final repo = _FakeStudentManuscriptRepository();
      final cubit = StudentManuscriptCheckerCubit(
        checkManuscriptUseCase: CheckManuscriptUseCase(repo),
        getAvailableJournalsUseCase: GetAvailableJournalsUseCase(repo),
      );

      expect(cubit.state, isA<StudentManuscriptCheckerInitial>());
      final initial = cubit.state as StudentManuscriptCheckerInitial;
      expect(initial.includeExemplars, isTrue);
      expect(initial.availableJournals, isEmpty);
    });

    blocTest<StudentManuscriptCheckerCubit, StudentManuscriptCheckerState>(
      'loadJournals emits loading then populates available journals',
      build: () {
        final repo = _FakeStudentManuscriptRepository();
        return StudentManuscriptCheckerCubit(
          checkManuscriptUseCase: CheckManuscriptUseCase(repo),
          getAvailableJournalsUseCase: GetAvailableJournalsUseCase(repo),
        );
      },
      act: (cubit) => cubit.loadJournals(),
      expect: () => [
        isA<StudentManuscriptCheckerInitial>()
            .having((s) => s.isLoadingJournals, 'isLoadingJournals', isTrue),
        isA<StudentManuscriptCheckerInitial>()
            .having((s) => s.isLoadingJournals, 'isLoadingJournals', isFalse)
            .having((s) => s.availableJournals.length, 'length', 1)
            .having((s) => s.selectedJournalId, 'selectedJournalId', 'j-1'),
      ],
    );

    test('selectJournal and updateDraftText update initial state', () {
      final repo = _FakeStudentManuscriptRepository();
      final cubit = StudentManuscriptCheckerCubit(
        checkManuscriptUseCase: CheckManuscriptUseCase(repo),
      );

      cubit.selectJournal('j-custom', 'Custom Title');
      expect(
        (cubit.state as StudentManuscriptCheckerInitial).selectedJournalId,
        'j-custom',
      );

      cubit.updateDraftText('Introduction\nDraft text');
      expect(
        (cubit.state as StudentManuscriptCheckerInitial).draftText,
        'Introduction\nDraft text',
      );

      cubit.setPickedFile('paper.pdf', [1, 2, 3]);
      expect(
        (cubit.state as StudentManuscriptCheckerInitial).fileName,
        'paper.pdf',
      );

      cubit.toggleIncludeExemplars(false);
      expect(
        (cubit.state as StudentManuscriptCheckerInitial).includeExemplars,
        isFalse,
      );
    });

    blocTest<StudentManuscriptCheckerCubit, StudentManuscriptCheckerState>(
      'submit with valid inputs emits Loading then Success',
      build: () {
        final repo = _FakeStudentManuscriptRepository();
        return StudentManuscriptCheckerCubit(
          checkManuscriptUseCase: CheckManuscriptUseCase(repo),
        );
      },
      act: (cubit) => cubit.submit(
        fileBytes: [1, 2, 3],
        filename: 'draft.txt',
        targetJournalId: 'j-1',
        includeExemplars: true,
        journalTitle: 'Target Journal',
      ),
      expect: () => [
        isA<StudentManuscriptCheckerLoading>(),
        isA<StudentManuscriptCheckerSuccess>()
            .having((s) => s.result.suitabilityScore, 'score', 85.0)
            .having((s) => s.targetJournalId, 'targetJournalId', 'j-1')
            .having((s) => s.manuscriptFileName, 'fileName', 'draft.txt'),
      ],
    );

    blocTest<StudentManuscriptCheckerCubit, StudentManuscriptCheckerState>(
      'submit with empty content emits Failure with validation message',
      build: () {
        final repo = _FakeStudentManuscriptRepository();
        return StudentManuscriptCheckerCubit(
          checkManuscriptUseCase: CheckManuscriptUseCase(repo),
        );
      },
      act: (cubit) => cubit.submit(
        fileBytes: [],
        filename: 'draft.txt',
        targetJournalId: 'j-1',
      ),
      expect: () => [
        isA<StudentManuscriptCheckerFailure>()
            .having((s) => s.message, 'message', contains('Please provide manuscript text')),
      ],
    );

    blocTest<StudentManuscriptCheckerCubit, StudentManuscriptCheckerState>(
      'submit with empty journal ID emits Failure with validation message',
      build: () {
        final repo = _FakeStudentManuscriptRepository();
        return StudentManuscriptCheckerCubit(
          checkManuscriptUseCase: CheckManuscriptUseCase(repo),
        );
      },
      act: (cubit) => cubit.submit(
        fileBytes: [1, 2, 3],
        filename: 'draft.txt',
        targetJournalId: '   ',
      ),
      expect: () => [
        isA<StudentManuscriptCheckerFailure>()
            .having((s) => s.message, 'message', contains('target journal ID')),
      ],
    );

    blocTest<StudentManuscriptCheckerCubit, StudentManuscriptCheckerState>(
      'submit when backend rejects throws Failure with cleaned message',
      build: () {
        final repo = _FakeStudentManuscriptRepository()
          ..error = const ServerException(
              'Unsupported manuscript file type; use PDF, DOCX, or TXT');
        return StudentManuscriptCheckerCubit(
          checkManuscriptUseCase: CheckManuscriptUseCase(repo),
        );
      },
      act: (cubit) => cubit.submit(
        fileBytes: [1, 2, 3],
        filename: 'draft.rtf',
        targetJournalId: 'j-1',
      ),
      expect: () => [
        isA<StudentManuscriptCheckerLoading>(),
        isA<StudentManuscriptCheckerFailure>()
            .having((s) => s.message, 'message', contains('Unsupported manuscript file type')),
      ],
    );

    blocTest<StudentManuscriptCheckerCubit, StudentManuscriptCheckerState>(
      'submit when result has 0 score, empty sections and no warnings emits Empty',
      build: () {
        final repo = _FakeStudentManuscriptRepository()
          ..result = const ManuscriptCheckResult(
            suitabilityScore: 0.0,
            ratingLevel: 'SIGNIFICANT_DEVIATION',
            summary: '',
            sectionScores: {},
            featureComparison: FeatureComparison(),
            warnings: [],
          );
        return StudentManuscriptCheckerCubit(
          checkManuscriptUseCase: CheckManuscriptUseCase(repo),
        );
      },
      act: (cubit) => cubit.submit(
        fileBytes: [1, 2, 3],
        filename: 'blank.txt',
        targetJournalId: 'j-1',
      ),
      expect: () => [
        isA<StudentManuscriptCheckerLoading>(),
        isA<StudentManuscriptCheckerEmpty>(),
      ],
    );

    test('reset clears submission and returns to initial state', () {
      final repo = _FakeStudentManuscriptRepository();
      final cubit = StudentManuscriptCheckerCubit(
        checkManuscriptUseCase: CheckManuscriptUseCase(repo),
      );
      cubit.reset();
      expect(cubit.state, isA<StudentManuscriptCheckerInitial>());
    });
  });
}
