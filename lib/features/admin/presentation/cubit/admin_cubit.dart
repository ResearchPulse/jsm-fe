import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/models/openalex_journal_model.dart';
import 'admin_state.dart';

class AdminCubit extends Cubit<AdminState> {
  final AdminRemoteDataSource dataSource;

  AdminCubit({AdminRemoteDataSource? remoteDataSource})
      : dataSource = remoteDataSource ?? AdminRemoteDataSource(),
        super(const AdminState());

  Future<void> searchOpenAlex(String? query, {int page = 1}) async {
    final q = query?.trim() ?? '';
    emit(state.copyWith(
      isSearching: true,
      searchQuery: q,
      searchError: null,
      currentPage: page,
    ));

    try {
      final result = await dataSource.searchOpenAlexJournals(
        search: q.isEmpty ? null : q,
        page: page,
        perPage: state.perPage,
      );
      emit(state.copyWith(
        openAlexJournals: result.items,
        totalCount: result.totalCount,
        currentPage: result.page,
        perPage: result.perPage,
        isSearching: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSearching: false,
        searchError: 'Không thể kết nối đến Backend: ${e.toString()}',
      ));
    }
  }

  Future<void> changeOpenAlexPage(int page) async {
    if (page == state.currentPage || state.isSearching || page < 1) return;
    await searchOpenAlex(state.searchQuery, page: page);
  }

  void selectJournalForConfig(OpenAlexJournalModel journal) {
    emit(state.copyWith(selectedJournalForConfig: journal));
  }

  void clearSelectedJournal() {
    emit(state.copyWith(clearSelectedJournal: true));
  }

  Future<void> loadConfigurations() async {
    emit(state.copyWith(isLoadingConfigs: true, configError: null));
    try {
      final configs = await dataSource.getConfigurations();
      emit(state.copyWith(
        configurations: configs,
        isLoadingConfigs: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingConfigs: false,
        configError: e.toString(),
      ));
    }
  }

  Future<void> loadJobs() async {
    emit(state.copyWith(isLoadingJobs: true));
    try {
      final jobs = await dataSource.getAnalysisJobs();
      emit(state.copyWith(
        jobs: jobs,
        isLoadingJobs: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingJobs: false));
    }
  }

  Future<bool> createConfigurationAndAnalyze({
    required OpenAlexJournalModel journal,
    required String domain,
    required int yearFrom,
    required int yearTo,
    required int targetArticles,
    String? referenceCorpusName,
  }) async {
    emit(state.copyWith(isTriggeringJob: true));
    try {
      final config = await dataSource.createConfiguration(
        journalId: journal.journalId,
        openalexJournal: journal.journalId == null ? journal : null,
        domain: domain,
        yearFrom: yearFrom,
        yearTo: yearTo,
        targetArticles: targetArticles,
        referenceCorpusName: referenceCorpusName,
      );

      final job = await dataSource.triggerAnalysis(config.id);

      emit(state.copyWith(
        isTriggeringJob: false,
        actionMessage: 'Đã tạo cấu hình và kích hoạt tiến trình phân tích thành công (Job: ${job.currentStep})!',
      ));

      // Refresh configs, jobs and openalex status
      await loadConfigurations();
      await loadJobs();
      await searchOpenAlex(state.searchQuery, page: state.currentPage);

      return true;
    } catch (e) {
      emit(state.copyWith(
        isTriggeringJob: false,
        actionMessage: 'Lỗi kích hoạt phân tích: ${e.toString()}',
      ));
      return false;
    }
  }

  Future<void> selectJob(String jobId) async {
    emit(state.copyWith(selectedJobId: jobId));
    await loadJobDetails(jobId);
  }

  void clearSelectedJob() {
    emit(state.copyWith(clearSelectedJobId: true, selectedJobArticles: const []));
  }

  Future<void> loadJobDetails(String jobId) async {
    emit(state.copyWith(isLoadingJobDetails: true));
    try {
      final metrics = await dataSource.getJobMetrics(jobId);
      final articles = await dataSource.getJobArticles(jobId);
      emit(state.copyWith(
        selectedJobMetrics: metrics,
        selectedJobArticles: articles,
        isLoadingJobDetails: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoadingJobDetails: false));
    }
  }

  Future<void> retryJobArticles(String jobId) async {
    emit(state.copyWith(isRetryingJob: true));
    try {
      await dataSource.retryFailedArticles(jobId);
      emit(state.copyWith(
        isRetryingJob: false,
        actionMessage: 'Đã gửi yêu cầu thử lại (Retry) các bài báo bị lỗi!',
      ));
      await loadJobDetails(jobId);
      await loadJobs();
    } catch (e) {
      emit(state.copyWith(
        isRetryingJob: false,
        actionMessage: 'Lỗi khi yêu cầu thử lại: ${e.toString()}',
      ));
    }
  }
}
