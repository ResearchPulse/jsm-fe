import '../entities/evaluation_history_response.dart';
import '../entities/evaluation_history_stats.dart';
import '../entities/journal_recommendation_response.dart';
import '../entities/manuscript_check_result.dart';
import '../entities/target_journal.dart';

/// Contract for checking student manuscripts against target journal style profiles.
abstract class StudentManuscriptRepository {
  /// Checks a manuscript against a target journal's style profile.
  ///
  /// Throws [ServerException] on rejection (unsupported format, missing journal,
  /// empty content, unparseable sections) and [NetworkException] when unreachable.
  Future<ManuscriptCheckResult> checkManuscript({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  });

  /// Streams real-time pipeline events during manuscript evaluation.
  Stream<Map<String, dynamic>> checkManuscriptStream({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) async* {
    final res = await checkManuscript(
      fileBytes: fileBytes,
      filename: filename,
      targetJournalId: targetJournalId,
      includeExemplars: includeExemplars,
    );
    yield {
      'event': 'analysis.completed',
      'stage': 'COMPLETED',
      'progress': 100,
      'message': 'Analysis complete',
      'data': res.toMap(),
    };
  }

  /// Fetches available journals that can be used for benchmarking.
  Future<List<TargetJournal>> getAvailableJournals();

  /// Retrieves paginated manuscript evaluation history.
  Future<EvaluationHistoryResponse> getEvaluationHistory({
    int page = 1,
    int limit = 10,
    String sort = 'newest',
    String? journal,
    String? compatibility,
    String? search,
  });

  /// Retrieves aggregate statistics for evaluations.
  Future<EvaluationHistoryStats> getEvaluationStats();

  /// Retrieves full snapshot of a specific historical evaluation.
  Future<ManuscriptCheckResult> getEvaluationDetail(String id);

  /// Deletes a specific evaluation by ID.
  Future<void> deleteEvaluation(String id);

  /// Analyzes a manuscript against all available journals to recommend the best match.
  /// Uses closed-world journals stored in the system.
  Future<JournalRecommendationResponse> getJournalRecommendations({
    List<int>? fileBytes,
    String? filename,
    String? evaluationId,
  });
}
