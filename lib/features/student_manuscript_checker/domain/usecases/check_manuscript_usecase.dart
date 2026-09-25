import '../entities/manuscript_check_result.dart';
import '../repositories/student_manuscript_repository.dart';

class CheckManuscriptUseCase {
  final StudentManuscriptRepository repository;

  const CheckManuscriptUseCase(this.repository);

  Future<ManuscriptCheckResult> call({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) {
    return repository.checkManuscript(
      fileBytes: fileBytes,
      filename: filename,
      targetJournalId: targetJournalId,
      includeExemplars: includeExemplars,
    );
  }
}
