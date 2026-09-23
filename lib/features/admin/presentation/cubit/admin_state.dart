import 'package:equatable/equatable.dart';
import '../../data/models/analysis_job_model.dart';
import '../../data/models/job_article_model.dart';
import '../../data/models/job_metrics_model.dart';
import '../../data/models/journal_configuration_model.dart';
import '../../data/models/openalex_journal_model.dart';

class AdminState extends Equatable {
  // Tab 1: OpenAlex Sources
  final List<OpenAlexJournalModel> openAlexJournals;
  final bool isSearching;
  final String? searchError;
  final String searchQuery;
  final int currentPage;
  final int totalCount;
  final int perPage;

  int get totalPages => perPage > 0 ? (totalCount / perPage).ceil() : 0;

  // Selected Journal to configure in Tab 2
  final OpenAlexJournalModel? selectedJournalForConfig;

  // Tab 2: Configurations
  final List<JournalConfigurationModel> configurations;
  final bool isLoadingConfigs;
  final String? configError;

  // Tab 3 / Job Monitor: Analysis Jobs
  final List<AnalysisJobModel> jobs;
  final bool isLoadingJobs;
  final bool isTriggeringJob;
  final String? actionMessage;

  // Selected Job Details & Metrics
  final String? selectedJobId;
  final JobMetricsModel? selectedJobMetrics;
  final List<JobArticleModel> selectedJobArticles;
  final bool isLoadingJobDetails;
  final bool isRetryingJob;

  const AdminState({
    this.openAlexJournals = const [],
    this.isSearching = false,
    this.searchError,
    this.searchQuery = '',
    this.currentPage = 1,
    this.totalCount = 0,
    this.perPage = 9,
    this.selectedJournalForConfig,
    this.configurations = const [],
    this.isLoadingConfigs = false,
    this.configError,
    this.jobs = const [],
    this.isLoadingJobs = false,
    this.isTriggeringJob = false,
    this.actionMessage,
    this.selectedJobId,
    this.selectedJobMetrics,
    this.selectedJobArticles = const [],
    this.isLoadingJobDetails = false,
    this.isRetryingJob = false,
  });

  AdminState copyWith({
    List<OpenAlexJournalModel>? openAlexJournals,
    bool? isSearching,
    String? searchError,
    String? searchQuery,
    int? currentPage,
    int? totalCount,
    int? perPage,
    OpenAlexJournalModel? selectedJournalForConfig,
    bool clearSelectedJournal = false,
    List<JournalConfigurationModel>? configurations,
    bool? isLoadingConfigs,
    String? configError,
    List<AnalysisJobModel>? jobs,
    bool? isLoadingJobs,
    bool? isTriggeringJob,
    String? actionMessage,
    String? selectedJobId,
    bool clearSelectedJobId = false,
    JobMetricsModel? selectedJobMetrics,
    List<JobArticleModel>? selectedJobArticles,
    bool? isLoadingJobDetails,
    bool? isRetryingJob,
  }) {
    return AdminState(
      openAlexJournals: openAlexJournals ?? this.openAlexJournals,
      isSearching: isSearching ?? this.isSearching,
      searchError: searchError,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      perPage: perPage ?? this.perPage,
      selectedJournalForConfig: clearSelectedJournal
          ? null
          : (selectedJournalForConfig ?? this.selectedJournalForConfig),
      configurations: configurations ?? this.configurations,
      isLoadingConfigs: isLoadingConfigs ?? this.isLoadingConfigs,
      configError: configError,
      jobs: jobs ?? this.jobs,
      isLoadingJobs: isLoadingJobs ?? this.isLoadingJobs,
      isTriggeringJob: isTriggeringJob ?? this.isTriggeringJob,
      actionMessage: actionMessage,
      selectedJobId: clearSelectedJobId ? null : (selectedJobId ?? this.selectedJobId),
      selectedJobMetrics: selectedJobMetrics ?? this.selectedJobMetrics,
      selectedJobArticles: selectedJobArticles ?? this.selectedJobArticles,
      isLoadingJobDetails: isLoadingJobDetails ?? this.isLoadingJobDetails,
      isRetryingJob: isRetryingJob ?? this.isRetryingJob,
    );
  }

  @override
  List<Object?> get props => [
        openAlexJournals,
        isSearching,
        searchError,
        searchQuery,
        currentPage,
        totalCount,
        perPage,
        selectedJournalForConfig,
        configurations,
        isLoadingConfigs,
        configError,
        jobs,
        isLoadingJobs,
        isTriggeringJob,
        actionMessage,
        selectedJobId,
        selectedJobMetrics,
        selectedJobArticles,
        isLoadingJobDetails,
        isRetryingJob,
      ];
}
