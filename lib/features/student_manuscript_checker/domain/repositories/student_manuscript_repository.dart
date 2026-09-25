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

  /// Fetches available journals that can be used for benchmarking.
  Future<List<TargetJournal>> getAvailableJournals();
}
