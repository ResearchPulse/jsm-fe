import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/features/admin/data/models/openalex_journal_model.dart';
import 'package:jsm_fe/features/admin/presentation/cubit/admin_state.dart';

void main() {
  group('Admin Pagination & Models', () {
    test('OpenAlexPaginatedResult calculates totalPages correctly', () {
      const result1 = OpenAlexPaginatedResult(
        items: [],
        totalCount: 35,
        page: 1,
        perPage: 9,
      );
      expect(result1.totalPages, 4);

      const result2 = OpenAlexPaginatedResult(
        items: [],
        totalCount: 27,
        page: 2,
        perPage: 9,
      );
      expect(result2.totalPages, 3);

      const result3 = OpenAlexPaginatedResult(
        items: [],
        totalCount: 0,
        page: 1,
        perPage: 9,
      );
      expect(result3.totalPages, 0);
    });

    test('AdminState pagination default values and copyWith', () {
      const state = AdminState();
      expect(state.currentPage, 1);
      expect(state.totalCount, 0);
      expect(state.perPage, 9);
      expect(state.totalPages, 0);

      final updated = state.copyWith(
        currentPage: 2,
        totalCount: 45,
        perPage: 9,
      );
      expect(updated.currentPage, 2);
      expect(updated.totalCount, 45);
      expect(updated.perPage, 9);
      expect(updated.totalPages, 5);
    });

    test('OpenAlexJournalModel parsing from JSON preserves fields', () {
      final json = {
        'openalex_id': 'https://openalex.org/S12345',
        'title': 'Test Medical Journal',
        'issn_l': '1234-5678',
        'publisher': 'Springer',
        'works_count': 1000,
        'cited_by_count': 5000,
        'analysis_status': 'NOT_ANALYZED',
      };

      final model = OpenAlexJournalModel.fromJson(json);
      expect(model.openalexId, 'https://openalex.org/S12345');
      expect(model.title, 'Test Medical Journal');
      expect(model.issnL, '1234-5678');
      expect(model.publisher, 'Springer');
      expect(model.worksCount, 1000);
      expect(model.citedByCount, 5000);
      expect(model.analysisStatus, AnalysisStatus.notAnalyzed);
    });
  });
}
