import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:jsm_fe/core/errors/exceptions.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/evaluation_history_response.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/evaluation_history_stats.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/feature_comparison.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/journal_recommendation_item.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/journal_recommendation_response.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/manuscript_check_result.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/target_journal.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/repositories/student_manuscript_repository.dart';
import 'package:jsm_fe/features/student_manuscript_checker/presentation/cubit/journal_recommendations_cubit.dart';
import 'package:jsm_fe/features/student_manuscript_checker/presentation/cubit/journal_recommendations_state.dart';

class _FakeRecommendationsRepository implements StudentManuscriptRepository {
  Object? error;
  JournalRecommendationResponse? response;
  List<TargetJournal> journals = const [
    TargetJournal(id: 'j-1', title: 'Journal Alpha'),
    TargetJournal(id: 'j-2', title: 'Journal Beta'),
  ];

  @override
  Future<List<TargetJournal>> getAvailableJournals() async {
    if (error != null) throw error!;
    return journals;
  }

  @override
  Future<JournalRecommendationResponse> getJournalRecommendations({
    List<int>? fileBytes,
    String? filename,
    String? evaluationId,
  }) async {
    if (error != null) throw error!;
    return response ??
        JournalRecommendationResponse(
          manuscriptName: filename ?? 'manuscript.pdf',
          totalWords: 1500,
          totalSentences: 80,
          candidateCount: 2,
          recommendations: [
            JournalRecommendationItem(
              rank: 1,
              journalId: 'j-1',
              journalName: 'Journal Alpha',
              compatibilityScore: 88.5,
              compatibilityLevel: 'STRONG_MATCH',
              dimensions: const RecommendationDimensionScores(
                structure: 90.0,
                sentenceStyle: 85.0,
                voiceAndPerson: 82.0,
                epistemicStyle: 88.0,
                rhetoricalMoves: 92.0,
              ),
              dataCoverage: 'HIGH',
              paperCount: 25,
              comparedDimensionsCount: 5,
              totalDimensionsCount: 5,
              strongestDimension: 'RHETORICAL_MOVES',
              weakestDimension: 'VOICE_PERSON',
              strongAlignments: ['Strong rhetorical move alignment'],
              notableDifferences: ['Slightly lower passive voice usage'],
              checkResult: const ManuscriptCheckResult(
                suitabilityScore: 88.5,
                ratingLevel: 'STRONG_MATCH',
                summary: 'Excellent alignment',
                sectionScores: {'INTRO': 90.0},
                featureComparison: FeatureComparison(),
              ),
            ),
          ],
        );
  }

  @override
  Future<ManuscriptCheckResult> checkManuscript({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<Map<String, dynamic>> checkManuscriptStream({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteEvaluation(String id) async {}

  @override
  Future<ManuscriptCheckResult> getEvaluationDetail(String id) {
    throw UnimplementedError();
  }

  @override
  Future<EvaluationHistoryResponse> getEvaluationHistory({
    int page = 1,
    int limit = 10,
    String sort = 'newest',
    String? journal,
    String? compatibility,
    String? search,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<EvaluationHistoryStats> getEvaluationStats() {
    throw UnimplementedError();
  }
}

void main() {
  group('JournalRecommendationsCubit Tests', () {
    late _FakeRecommendationsRepository repository;

    setUp(() {
      repository = _FakeRecommendationsRepository();
    });

    test('initial state has default values', () {
      final cubit = JournalRecommendationsCubit(repository: repository);
      expect(cubit.state.status, JournalRecommendationsStatus.initial);
      expect(cubit.state.availableJournalsCount, 0);
      expect(cubit.state.selectedEvaluationId, isNull);
      expect(cubit.state.fileBytes, isNull);
    });

    test('init loads available journals count', () async {
      final cubit = JournalRecommendationsCubit(repository: repository);
      await cubit.init();
      expect(cubit.state.availableJournalsCount, 2);
    });

    test('selectFile sets file info and clears evaluation id', () {
      final cubit = JournalRecommendationsCubit(repository: repository);
      cubit.selectEvaluationId('eval-123', 'old.pdf');
      expect(cubit.state.selectedEvaluationId, 'eval-123');

      cubit.selectFile(filename: 'new.pdf', bytes: [1, 2, 3]);
      expect(cubit.state.fileName, 'new.pdf');
      expect(cubit.state.fileBytes, [1, 2, 3]);
      expect(cubit.state.selectedEvaluationId, isNull);
    });

    test('selectEvaluationId sets id and clears file info', () {
      final cubit = JournalRecommendationsCubit(repository: repository);
      cubit.selectFile(filename: 'new.pdf', bytes: [1, 2, 3]);

      cubit.selectEvaluationId('eval-999', 'eval_paper.pdf');
      expect(cubit.state.selectedEvaluationId, 'eval-999');
      expect(cubit.state.fileName, 'eval_paper.pdf');
      expect(cubit.state.fileBytes, isNull);
    });

    blocTest<JournalRecommendationsCubit, JournalRecommendationsState>(
      'submitRecommendationRequest emits loading stages and success with recommendations',
      build: () {
        final cubit = JournalRecommendationsCubit(repository: repository);
        cubit.selectFile(filename: 'paper.pdf', bytes: [10, 20]);
        return cubit;
      },
      act: (cubit) => cubit.submitRecommendationRequest(),
      expect: () => [
        predicate<JournalRecommendationsState>(
          (s) =>
              s.status == JournalRecommendationsStatus.loading &&
              s.pipelineStage == 'PREPARING_MANUSCRIPT',
        ),
        predicate<JournalRecommendationsState>(
          (s) =>
              s.status == JournalRecommendationsStatus.loading &&
              s.pipelineStage == 'FETCHING_JOURNALS',
        ),
        predicate<JournalRecommendationsState>(
          (s) =>
              s.status == JournalRecommendationsStatus.loading &&
              s.pipelineStage == 'COMPARING_PROFILES',
        ),
        predicate<JournalRecommendationsState>(
          (s) =>
              s.status == JournalRecommendationsStatus.success &&
              s.recommendationResponse != null &&
              s.recommendationResponse!.recommendations.length == 1,
        ),
      ],
    );

    blocTest<JournalRecommendationsCubit, JournalRecommendationsState>(
      'submitRecommendationRequest emits failure when repository throws ServerException',
      build: () {
        repository.error = const ServerException('Database error');
        final cubit = JournalRecommendationsCubit(repository: repository);
        cubit.selectEvaluationId('eval-1', 'paper.pdf');
        return cubit;
      },
      act: (cubit) => cubit.submitRecommendationRequest(),
      expect: () => [
        predicate<JournalRecommendationsState>(
          (s) => s.status == JournalRecommendationsStatus.loading,
        ),
        predicate<JournalRecommendationsState>(
          (s) => s.status == JournalRecommendationsStatus.loading,
        ),
        predicate<JournalRecommendationsState>(
          (s) => s.status == JournalRecommendationsStatus.loading,
        ),
        predicate<JournalRecommendationsState>(
          (s) =>
              s.status == JournalRecommendationsStatus.failure &&
              s.errorMessage == 'Database error',
        ),
      ],
    );

    test('viewComparison and closeComparison manage detailed view state', () {
      final cubit = JournalRecommendationsCubit(repository: repository);
      final item = JournalRecommendationItem(
        rank: 1,
        journalId: 'j-1',
        journalName: 'Journal Alpha',
        compatibilityScore: 88.5,
        compatibilityLevel: 'STRONG_MATCH',
        dimensions: const RecommendationDimensionScores(
          structure: 90.0,
          sentenceStyle: 85.0,
          voiceAndPerson: 82.0,
          epistemicStyle: 88.0,
          rhetoricalMoves: 92.0,
        ),
        dataCoverage: 'HIGH',
        paperCount: 25,
        comparedDimensionsCount: 5,
        totalDimensionsCount: 5,
        strongestDimension: 'RHETORICAL_MOVES',
        weakestDimension: 'VOICE_PERSON',
        strongAlignments: const [],
        notableDifferences: const [],
        checkResult: const ManuscriptCheckResult(
          suitabilityScore: 88.5,
          ratingLevel: 'STRONG_MATCH',
          summary: 'High match',
          sectionScores: {},
          featureComparison: FeatureComparison(),
        ),
      );

      cubit.viewComparison(item);
      expect(cubit.state.hasDetailedView, isTrue);
      expect(cubit.state.selectedJournalForDetailedView, item);

      cubit.closeComparison();
      expect(cubit.state.hasDetailedView, isFalse);
      expect(cubit.state.selectedJournalForDetailedView, isNull);
    });
  });
}
