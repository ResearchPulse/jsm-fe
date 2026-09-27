import '../../../../core/errors/exceptions.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/evaluation_history_response.dart';
import '../../domain/entities/evaluation_history_stats.dart';
import '../../domain/entities/journal_recommendation_response.dart';
import '../../domain/entities/manuscript_check_result.dart';
import '../../domain/entities/target_journal.dart';
import '../../domain/repositories/student_manuscript_repository.dart';
import '../datasources/student_manuscript_api_client.dart';

class StudentManuscriptRepositoryImpl implements StudentManuscriptRepository {
  final StudentManuscriptApiClient apiClient;

  StudentManuscriptRepositoryImpl({AuthRepository? authRepository})
      : apiClient = StudentManuscriptApiClient(
          tokenProvider:
              authRepository != null ? () => authRepository.currentToken() : null,
        );

  /// Direct injection constructor for tests.
  StudentManuscriptRepositoryImpl.withClient(this.apiClient);

  @override
  Future<ManuscriptCheckResult> checkManuscript({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) async {
    final cleanJournalId = targetJournalId.trim();
    if (cleanJournalId.isEmpty) {
      throw const ServerException(
        'Please select or enter a target journal ID.',
        400,
      );
    }

    if (fileBytes.isEmpty) {
      throw const ServerException(
        'The manuscript is empty.',
        400,
      );
    }

    final cleanFilename =
        filename.trim().isEmpty ? 'manuscript.txt' : filename.trim();

    return apiClient.checkManuscript(
      fileBytes: fileBytes,
      filename: cleanFilename,
      targetJournalId: cleanJournalId,
      includeExemplars: includeExemplars,
    );
  }

  @override
  Stream<Map<String, dynamic>> checkManuscriptStream({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) {
    final cleanJournalId = targetJournalId.trim();
    final cleanFilename =
        filename.trim().isEmpty ? 'manuscript.txt' : filename.trim();

    return apiClient.checkManuscriptStream(
      fileBytes: fileBytes,
      filename: cleanFilename,
      targetJournalId: cleanJournalId,
      includeExemplars: includeExemplars,
    );
  }

  @override
  Future<List<TargetJournal>> getAvailableJournals() {
    return apiClient.getAvailableJournals();
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
    return apiClient.getEvaluationHistory(
      page: page,
      limit: limit,
      sort: sort,
      journal: journal,
      compatibility: compatibility,
      search: search,
    );
  }

  @override
  Future<EvaluationHistoryStats> getEvaluationStats() {
    return apiClient.getEvaluationStats();
  }

  @override
  Future<ManuscriptCheckResult> getEvaluationDetail(String id) {
    return apiClient.getEvaluationDetail(id);
  }

  @override
  Future<void> deleteEvaluation(String id) {
    return apiClient.deleteEvaluation(id);
  }

  @override
  Future<JournalRecommendationResponse> getJournalRecommendations({
    List<int>? fileBytes,
    String? filename,
    String? evaluationId,
  }) {
    if ((fileBytes == null || fileBytes.isEmpty) &&
        (evaluationId == null || evaluationId.trim().isEmpty)) {
      throw const ServerException(
        'Vui lòng cung cấp tệp bản thảo hoặc chọn lịch sử đánh giá.',
        400,
      );
    }
    return apiClient.getJournalRecommendations(
      fileBytes: fileBytes,
      filename: filename,
      evaluationId: evaluationId?.trim(),
    );
  }
}

