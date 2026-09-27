import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/student_manuscript_repository.dart';
import 'evaluation_history_state.dart';

class EvaluationHistoryCubit extends Cubit<EvaluationHistoryState> {
  final StudentManuscriptRepository _repository;

  EvaluationHistoryCubit({required StudentManuscriptRepository repository})
    : _repository = repository,
      super(const EvaluationHistoryState());

  /// Loads evaluations and stats based on current filter/sort/pagination state.
  Future<void> loadHistory({bool refreshStats = false}) async {
    emit(
      state.copyWith(
        status: EvaluationHistoryStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final responseFuture = _repository.getEvaluationHistory(
        page: state.page,
        limit: state.limit,
        sort: state.sort,
        journal: state.journal,
        compatibility: state.compatibility,
        search: state.search,
      );

      final statsFuture = refreshStats || state.stats.totalEvaluations == 0
          ? _repository.getEvaluationStats()
          : Future.value(state.stats);

      final results = await Future.wait([responseFuture, statsFuture]);
      final historyResponse = results[0] as dynamic;
      final statsResponse = results[1] as dynamic;

      emit(
        state.copyWith(
          status: EvaluationHistoryStatus.success,
          items: historyResponse.items,
          page: historyResponse.page,
          limit: historyResponse.limit,
          total: historyResponse.total,
          totalPages: historyResponse.totalPages,
          stats: statsResponse,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EvaluationHistoryStatus.failure,
          errorMessage: 'Unable to load evaluation history. ${e.toString()}',
        ),
      );
    }
  }

  /// Changes the search query with reset to page 1.
  void setSearch(String query) {
    emit(state.copyWith(search: query, page: 1));
    loadHistory();
  }

  /// Filters by journal with reset to page 1.
  void setJournal(String? journal) {
    emit(
      state.copyWith(journal: journal, page: 1, clearJournal: journal == null),
    );
    loadHistory();
  }

  /// Filters by compatibility with reset to page 1.
  void setCompatibility(String? compatibility) {
    emit(
      state.copyWith(
        compatibility: compatibility,
        page: 1,
        clearCompatibility: compatibility == null || compatibility == 'ALL',
      ),
    );
    loadHistory();
  }

  /// Changes sort order with reset to page 1.
  void setSort(String sort) {
    emit(state.copyWith(sort: sort, page: 1));
    loadHistory();
  }

  /// Changes pagination page.
  void changePage(int page) {
    if (page < 1 || (state.totalPages > 0 && page > state.totalPages)) return;
    emit(state.copyWith(page: page));
    loadHistory();
  }

  /// Clears all active filters.
  void clearFilters() {
    emit(
      state.copyWith(
        search: '',
        page: 1,
        clearJournal: true,
        clearCompatibility: true,
      ),
    );
    loadHistory();
  }

  /// Deletes an evaluation item and reloads the list.
  Future<bool> deleteEvaluation(String id) async {
    emit(state.copyWith(isDeleting: true));
    try {
      await _repository.deleteEvaluation(id);
      // Reload list and refresh stats
      await loadHistory(refreshStats: true);
      emit(state.copyWith(isDeleting: false));
      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isDeleting: false,
          errorMessage: 'Failed to delete evaluation. ${e.toString()}',
        ),
      );
      return false;
    }
  }
}
