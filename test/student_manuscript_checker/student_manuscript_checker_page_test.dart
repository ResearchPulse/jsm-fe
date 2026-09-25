import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/app/theme/app_theme.dart';
import 'package:jsm_fe/core/widgets/error_view.dart';
import 'package:jsm_fe/core/widgets/loading_view.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/exemplar_item.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/feature_comparison.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/manuscript_check_result.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/sentence_length_comparison.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/stance_comparison.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/target_journal.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/voice_person_comparison.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/warning_item.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/repositories/student_manuscript_repository.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/usecases/check_manuscript_usecase.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/usecases/get_available_journals_usecase.dart';
import 'package:jsm_fe/features/student_manuscript_checker/presentation/cubit/student_manuscript_checker_cubit.dart';
import 'package:jsm_fe/features/student_manuscript_checker/presentation/cubit/student_manuscript_checker_state.dart';
import 'package:jsm_fe/features/student_manuscript_checker/presentation/pages/student_manuscript_checker_page.dart';
import 'package:jsm_fe/features/student_manuscript_checker/presentation/widgets/manuscript_input_card.dart';

class _MockRepo implements StudentManuscriptRepository {
  ManuscriptCheckResult? resultToReturn;
  Object? errorToThrow;
  List<TargetJournal> journals = const [
    TargetJournal(
      id: 'j-uuid-101',
      title: 'IEEE Transactions on Software Engineering',
      domain: 'Software Engineering',
    ),
  ];

  @override
  Future<ManuscriptCheckResult> checkManuscript({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return resultToReturn ?? _defaultResult();
  }

  @override
  Future<List<TargetJournal>> getAvailableJournals() async {
    if (errorToThrow != null) throw errorToThrow!;
    return journals;
  }
}

class _SlowRepo extends _MockRepo {
  @override
  Future<ManuscriptCheckResult> checkManuscript({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _defaultResult();
  }
}

ManuscriptCheckResult _defaultResult({
  bool includeMissingGap = true,
  bool includeExemplar = true,
}) {
  return ManuscriptCheckResult(
    suitabilityScore: 88.5,
    ratingLevel: 'EXCELLENT_ALIGNMENT',
    summary:
        'The manuscript shows excellent alignment with the target journal.',
    sectionScores: const {
      'INTRO': 92.0,
      'METHODS': 85.0,
    },
    featureComparison: const FeatureComparison(
      sentenceLength: SentenceLengthComparison(
        userMedian: 19.5,
        journalMedian: 20.0,
        journalP10: 12.0,
        journalP90: 28.0,
        status: 'WITHIN_RANGE',
      ),
      voiceAndPerson: VoicePersonComparison(
        userPassiveRate: 0.24,
        journalPassiveRate: 0.22,
        userWeRate: 0.05,
        journalWeRate: 0.08,
      ),
      stance: StanceComparison(
        userHedgeRate: 12.5,
        journalHedgeRate: 15.0,
        userBoosterRate: 8.0,
        journalBoosterRate: 9.0,
      ),
    ),
    warnings: [
      if (includeMissingGap)
        WarningItem(
          id: 'W-GAP-01',
          severity: 'CRITICAL',
          section: 'INTRO',
          title: 'Missing Research Gap',
          message: 'The manuscript section does not contain a research gap.',
          exemplar: includeExemplar
              ? const ExemplarItem(
                  text: 'However, prior approaches remain limited.',
                  articleTitle: 'A Benchmark Empirical Study',
                  doi: '10.1109/TSE.2024.12345',
                )
              : null,
        ),
      const WarningItem(
        id: 'W-STYLE-01',
        severity: 'HIGH',
        section: 'METHODS',
        title: 'Sentence Length Outside Journal Range',
        message: 'Median sentence length exceeds expected journal band.',
      ),
    ],
  );
}

Widget _buildTestApp({
  required StudentManuscriptCheckerCubit cubit,
}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: StudentManuscriptCheckerPage(cubit: cubit),
  );
}

void main() {
  group('StudentManuscriptCheckerPage Widget Tests', () {
    testWidgets('renders input form with journal selection and sample loader',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = _MockRepo();
      final cubit = StudentManuscriptCheckerCubit(
        checkManuscriptUseCase: CheckManuscriptUseCase(repo),
        getAvailableJournalsUseCase: GetAvailableJournalsUseCase(repo),
      );

      await tester.pumpWidget(_buildTestApp(cubit: cubit));
      await tester.pumpAndSettle();

      expect(find.text('Student Manuscript Checker'), findsOneWidget);
      expect(find.byType(ManuscriptInputCard), findsOneWidget);
      expect(find.text('Direct Text / Draft'), findsOneWidget);
      expect(find.text('Upload File'), findsOneWidget);
      expect(find.text('Load Sample Manuscript'), findsOneWidget);
      expect(find.text('Include validated exemplars from journal corpus'),
          findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Check Manuscript Alignment'),
          findsOneWidget);

      // Tap "Load Sample Manuscript"
      await tester.tap(find.text('Load Sample Manuscript'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Recent deep learning architectures'),
          findsOneWidget);
    });

    testWidgets(
        'submitting valid manuscript shows loading then full results dashboard',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repo = _SlowRepo();
      final cubit = StudentManuscriptCheckerCubit(
        checkManuscriptUseCase: CheckManuscriptUseCase(repo),
        getAvailableJournalsUseCase: GetAvailableJournalsUseCase(repo),
      );
      await cubit.loadJournals();

      await tester.pumpWidget(_buildTestApp(cubit: cubit));
      await tester.pumpAndSettle();

      // Load sample text
      await tester.tap(find.text('Load Sample Manuscript'));
      await tester.pumpAndSettle();

      // Scroll submit button into view and submit
      final submitFinder =
          find.widgetWithText(ElevatedButton, 'Check Manuscript Alignment');
      await tester.ensureVisible(submitFinder);
      await tester.pumpAndSettle();

      await tester.tap(submitFinder);
      await tester.pump();
      await tester.pump();

      // Verify Loading View during background delay
      expect(find.byType(LoadingView), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Settle once background check completes
      await tester.pumpAndSettle();

      // Verify Success Dashboard
      expect(find.text('88.5'), findsOneWidget);
      expect(find.text('Excellent Alignment'), findsOneWidget);
      expect(find.text('Suitability Assessment'), findsOneWidget);

      // Verify Missing GAP alert card
      expect(find.text('Missing Research Gap'), findsWidgets);
      expect(find.text('CRITICAL MOVE'), findsOneWidget);
      expect(find.text('Validated Journal Exemplar'), findsOneWidget);
      expect(find.text('“However, prior approaches remain limited.”'),
          findsWidgets);
      expect(find.text('DOI: 10.1109/TSE.2024.12345'), findsWidgets);

      // Verify Breakdown Cards
      expect(find.text('Section Alignment Scores'), findsOneWidget);
      expect(find.text('Sentence Length Analysis'), findsOneWidget);
      expect(find.text('Voice & Person Comparison'), findsOneWidget);
      expect(find.text('Stance & Epistemic Markers'), findsOneWidget);
      expect(find.text('Rhetorical Move Analysis'), findsOneWidget);
      expect(find.text('Diagnostics & Style Warnings'), findsOneWidget);

      // Verify Reset Action
      expect(find.text('New Check'), findsOneWidget);
      await tester.tap(find.text('New Check'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Check Manuscript Alignment'),
          findsOneWidget);
    });

    testWidgets('shows ErrorView when failure state is emitted',
        (tester) async {
      final repo = _MockRepo();
      final cubit = StudentManuscriptCheckerCubit(
        checkManuscriptUseCase: CheckManuscriptUseCase(repo),
      );

      await tester.pumpWidget(_buildTestApp(cubit: cubit));
      await tester.pumpAndSettle();

      cubit.emit(const StudentManuscriptCheckerFailure(
        message: 'Could not connect to analysis service.',
      ));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Could not connect to analysis service.'), findsOneWidget);
      expect(find.text('Return to Submission Form'), findsOneWidget);

      await tester.tap(find.text('Return to Submission Form'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Check Manuscript Alignment'),
          findsOneWidget);
    });

    testWidgets('shows Empty view when manuscript has no readable sections',
        (tester) async {
      final repo = _MockRepo();
      final cubit = StudentManuscriptCheckerCubit(
        checkManuscriptUseCase: CheckManuscriptUseCase(repo),
      );

      await tester.pumpWidget(_buildTestApp(cubit: cubit));
      await tester.pumpAndSettle();

      cubit.emit(const StudentManuscriptCheckerEmpty(
        message: 'The manuscript is empty or contains no readable sections.',
      ));
      await tester.pumpAndSettle();

      expect(find.text('No Manuscript Sections Found'), findsOneWidget);
      expect(find.text('Submit Another Draft'), findsOneWidget);

      await tester.tap(find.text('Submit Another Draft'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ElevatedButton, 'Check Manuscript Alignment'),
          findsOneWidget);
    });
  });
}
