import '../entities/target_journal.dart';
import '../repositories/student_manuscript_repository.dart';

class GetAvailableJournalsUseCase {
  final StudentManuscriptRepository repository;

  const GetAvailableJournalsUseCase(this.repository);

  Future<List<TargetJournal>> call() {
    return repository.getAvailableJournals();
  }
}
