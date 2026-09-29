import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/evaluation_history_item.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/evaluation_history_response.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/evaluation_history_stats.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/journal_recommendation_response.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/manuscript_check_result.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/target_journal.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/repositories/student_manuscript_repository.dart';
import 'package:jsm_fe/features/student_manuscript_checker/presentation/cubit/evaluation_history_cubit.dart';
import 'package:jsm_fe/features/student_manuscript_checker/presentation/cubit/evaluation_history_state.dart';

class _FakeHistoryRepository implements StudentManuscriptRepository {
  List<EvaluationHistoryItem> mockItems = [];
  bool shouldThrow = false;
  bool deletedCalled = false;

  @override
  Future<EvaluationHistoryResponse> getEvaluationHistory({
    int page = 1,
    int limit = 10,
    String sort = 'newest',
    String? journal,
    String? compatibility,
    String? search,
  }) async {
    if (shouldThrow) throw Exception('API Error');
    return EvaluationHistoryResponse(
      items: mockItems,
      page: page,
      limit: limit,
      total: mockItems.length,
      totalPages: 1,
    );
  }

  @override
  Future<EvaluationHistoryStats> getEvaluationStats() async {
    if (shouldThrow) throw Exception('API Error');
    return const EvaluationHistoryStats(
      totalEvaluations: 2,
      strongMatches: 1,
      needRevision: 1,
      averageCompatibility: 80.0,
    );
  }

  @override
  Future<void> deleteEvaluation(String id) async {
    if (shouldThrow) throw Exception('Delete Error');
    deletedCalled = true;
    mockItems.removeWhere((item) => item.id == id);
  }

  @override
  Future<ManuscriptCheckResult> getEvaluationDetail(String id) async {
    throw UnimplementedError();
  }

  @override
  Future<ManuscriptCheckResult> checkManuscript({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Stream<Map<String, dynamic>> checkManuscriptStream({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) async* {}

  @override
  Future<List<TargetJournal>> getAvailableJournals() async => [];

  @override
  Future<JournalRecommendationResponse> getJournalRecommendations({
    List<int>? fileBytes,
    String? filename,
    String? evaluationId,
  }) async {
    return const JournalRecommendationResponse(
      manuscriptName: 'draft.pdf',
      totalWords: 1000,
      totalSentences: 50,
      candidateCount: 0,
      recommendations: [],
    );
  }
}

void main() {
  group('EvaluationHistoryCubit Tests', () {
    late _FakeHistoryRepository repo;

    setUp(() {
      repo = _FakeHistoryRepository();
      repo.mockItems = [
        EvaluationHistoryItem(
          id: 'eval-1',
          fileName: 'draft.pdf',
          journalName: 'IEEE Access',
          overallScore: 85.0,
          compatibilityLevel: 'STRONG_MATCH',
          recommendation: 'READY',
          criticalMismatchCount: 0,
          status: 'COMPLETED',
          createdAt: DateTime(2026, 9, 27),
        ),
      ];
    });

    test('initial state is correct', () {
      final cubit = EvaluationHistoryCubit(repository: repo);
      expect(cubit.state, const EvaluationHistoryState());
      cubit.close();
    });

    blocTest<EvaluationHistoryCubit, EvaluationHistoryState>(
      'loadHistory emits loading and success with items and stats',
      build: () => EvaluationHistoryCubit(repository: repo),
      act: (cubit) => cubit.loadHistory(refreshStats: true),
      expect: () => [
        isA<EvaluationHistoryState>().having(
          (s) => s.status,
          'status',
          EvaluationHistoryStatus.loading,
        ),
        isA<EvaluationHistoryState>()
            .having((s) => s.status, 'status', EvaluationHistoryStatus.success)
            .having((s) => s.items.length, 'items count', 1)
            .having((s) => s.stats.totalEvaluations, 'stats total', 2),
      ],
    );

    blocTest<EvaluationHistoryCubit, EvaluationHistoryState>(
      'setSearch updates search query and reloads',
      build: () => EvaluationHistoryCubit(repository: repo),
      act: (cubit) => cubit.setSearch('nature'),
      expect: () => [
        isA<EvaluationHistoryState>()
            .having((s) => s.search, 'search', 'nature')
            .having((s) => s.status, 'status', EvaluationHistoryStatus.initial),
        isA<EvaluationHistoryState>()
            .having((s) => s.search, 'search', 'nature')
            .having((s) => s.status, 'status', EvaluationHistoryStatus.loading),
        isA<EvaluationHistoryState>().having(
          (s) => s.status,
          'status',
          EvaluationHistoryStatus.success,
        ),
      ],
    );

    blocTest<EvaluationHistoryCubit, EvaluationHistoryState>(
      'setCompatibility filters by compatibility level',
      build: () => EvaluationHistoryCubit(repository: repo),
      act: (cubit) => cubit.setCompatibility('STRONG_MATCH'),
      expect: () => [
        isA<EvaluationHistoryState>()
            .having((s) => s.compatibility, 'compatibility', 'STRONG_MATCH')
            .having((s) => s.status, 'status', EvaluationHistoryStatus.initial),
        isA<EvaluationHistoryState>()
            .having((s) => s.compatibility, 'compatibility', 'STRONG_MATCH')
            .having((s) => s.status, 'status', EvaluationHistoryStatus.loading),
        isA<EvaluationHistoryState>().having(
          (s) => s.status,
          'status',
          EvaluationHistoryStatus.success,
        ),
      ],
    );

    blocTest<EvaluationHistoryCubit, EvaluationHistoryState>(
      'clearFilters resets search and compatibility',
      build: () => EvaluationHistoryCubit(repository: repo),
      act: (cubit) => cubit.clearFilters(),
      expect: () => [
        isA<EvaluationHistoryState>()
            .having((s) => s.search, 'search', '')
            .having((s) => s.compatibility, 'compatibility', isNull)
            .having((s) => s.status, 'status', EvaluationHistoryStatus.initial),
        isA<EvaluationHistoryState>()
            .having((s) => s.search, 'search', '')
            .having((s) => s.compatibility, 'compatibility', isNull)
            .having((s) => s.status, 'status', EvaluationHistoryStatus.loading),
        isA<EvaluationHistoryState>().having(
          (s) => s.status,
          'status',
          EvaluationHistoryStatus.success,
        ),
      ],
    );

    blocTest<EvaluationHistoryCubit, EvaluationHistoryState>(
      'deleteEvaluation deletes item and refreshes',
      build: () => EvaluationHistoryCubit(repository: repo),
      act: (cubit) => cubit.deleteEvaluation('eval-1'),
      expect: () => [
        isA<EvaluationHistoryState>().having(
          (s) => s.isDeleting,
          'isDeleting',
          true,
        ),
        isA<EvaluationHistoryState>().having(
          (s) => s.status,
          'status',
          EvaluationHistoryStatus.loading,
        ),
        isA<EvaluationHistoryState>()
            .having((s) => s.status, 'status', EvaluationHistoryStatus.success)
            .having((s) => s.items.length, 'items after delete', 0),
        isA<EvaluationHistoryState>().having(
          (s) => s.isDeleting,
          'isDeleting',
          false,
        ),
      ],
    );
  });
}
