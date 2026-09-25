import '../../../../core/errors/exceptions.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
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
  Future<List<TargetJournal>> getAvailableJournals() {
    return apiClient.getAvailableJournals();
  }
}
