import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jsm_fe/core/errors/exceptions.dart';
import 'package:jsm_fe/features/student_manuscript_checker/data/datasources/student_manuscript_api_client.dart';
import 'package:jsm_fe/features/student_manuscript_checker/data/repositories/student_manuscript_repository_impl.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/feature_comparison.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/manuscript_check_result.dart';
import 'package:jsm_fe/features/student_manuscript_checker/domain/entities/target_journal.dart';

class _FakeApiClient extends StudentManuscriptApiClient {
  Object? errorToThrow;
  ManuscriptCheckResult? resultToReturn;
  List<TargetJournal>? journalsToReturn;

  _FakeApiClient() : super(client: MockClient((_) async => http.Response('', 200)));

  @override
  Future<ManuscriptCheckResult> checkManuscript({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return resultToReturn ??
        const ManuscriptCheckResult(
          suitabilityScore: 80.0,
          ratingLevel: 'MODERATE_ALIGNMENT',
          summary: 'Summary',
          sectionScores: {'INTRO': 80.0},
          featureComparison: FeatureComparison(),
        );
  }

  @override
  Future<List<TargetJournal>> getAvailableJournals() async {
    if (errorToThrow != null) throw errorToThrow!;
    return journalsToReturn ??
        const [
          TargetJournal(id: 'j1', title: 'Target Journal 1'),
        ];
  }
}

void main() {
  group('StudentManuscriptRepositoryImpl', () {
    test('validation: throws ServerException if targetJournalId is blank',
        () async {
      final fakeClient = _FakeApiClient();
      final repo = StudentManuscriptRepositoryImpl.withClient(fakeClient);

      await expectLater(
        repo.checkManuscript(
          fileBytes: [1, 2, 3],
          filename: 'draft.txt',
          targetJournalId: '   ',
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('target journal'),
          ),
        ),
      );
    });

    test('validation: throws ServerException if fileBytes is empty', () async {
      final fakeClient = _FakeApiClient();
      final repo = StudentManuscriptRepositoryImpl.withClient(fakeClient);

      await expectLater(
        repo.checkManuscript(
          fileBytes: [],
          filename: 'draft.txt',
          targetJournalId: 'j-uuid',
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('empty'),
          ),
        ),
      );
    });

    test('success: delegates to client with default filename if empty',
        () async {
      final fakeClient = _FakeApiClient();
      final repo = StudentManuscriptRepositoryImpl.withClient(fakeClient);

      final result = await repo.checkManuscript(
        fileBytes: [65, 66, 67],
        filename: '',
        targetJournalId: 'j-uuid',
        includeExemplars: true,
      );

      expect(result.suitabilityScore, 80.0);
      expect(result.ratingLevel, 'MODERATE_ALIGNMENT');
      expect(result.isModerate, isTrue);
    });

    test('getAvailableJournals delegates to apiClient', () async {
      final fakeClient = _FakeApiClient();
      final repo = StudentManuscriptRepositoryImpl.withClient(fakeClient);

      final journals = await repo.getAvailableJournals();
      expect(journals.length, 1);
      expect(journals.first.id, 'j1');
    });
  });
}
