import '../../../../core/network/api_client.dart';
import '../models/analysis_job_model.dart';
import '../models/job_article_model.dart';
import '../models/job_metrics_model.dart';
import '../models/journal_configuration_model.dart';
import '../models/openalex_journal_model.dart';

class AdminRemoteDataSource {
  final ApiClient apiClient;

  AdminRemoteDataSource({ApiClient? client}) : apiClient = client ?? ApiClient();

  Future<OpenAlexPaginatedResult> searchOpenAlexJournals({
    String? search,
    int page = 1,
    int perPage = 9,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await apiClient.dio.get(
      '/admin/journals/openalex',
      queryParameters: queryParams,
    );

    final data = response.data['data'] as Map<String, dynamic>;
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((item) => OpenAlexJournalModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return OpenAlexPaginatedResult(
      items: items,
      totalCount: data['total_count'] as int? ?? items.length,
      page: data['page'] as int? ?? page,
      perPage: data['per_page'] as int? ?? perPage,
    );
  }

  Future<List<JournalConfigurationModel>> getConfigurations() async {
    final response = await apiClient.dio.get('/admin/journal-configurations');
    final items = response.data['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => JournalConfigurationModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<JournalConfigurationModel> createConfiguration({
    String? journalId,
    OpenAlexJournalModel? openalexJournal,
    required String domain,
    required int yearFrom,
    required int yearTo,
    required int targetArticles,
    String? referenceCorpusName,
  }) async {
    final body = <String, dynamic>{
      'domain': domain,
      'year_from': yearFrom,
      'year_to': yearTo,
      'target_articles': targetArticles,
      'reference_corpus_name': referenceCorpusName ?? 'Other $domain Journals',
      'is_active': true,
    };

    if (journalId != null) {
      body['journal_id'] = journalId;
    } else if (openalexJournal != null) {
      body['openalex_journal'] = openalexJournal.toImportJson();
    }

    final response = await apiClient.dio.post(
      '/admin/journal-configurations',
      data: body,
    );

    return JournalConfigurationModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<AnalysisJobModel> triggerAnalysis(String configurationId) async {
    final response = await apiClient.dio.post(
      '/admin/journal-configurations/$configurationId/analyze',
    );
    return AnalysisJobModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<AnalysisJobModel>> getAnalysisJobs() async {
    final response = await apiClient.dio.get('/admin/analysis-jobs');
    final items = response.data['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => AnalysisJobModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<JobMetricsModel> getJobMetrics(String jobId) async {
    final response = await apiClient.dio.get('/admin/analysis-jobs/$jobId/metrics');
    return JobMetricsModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<List<JobArticleModel>> getJobArticles(
    String jobId, {
    int page = 1,
    int perPage = 50,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    final response = await apiClient.dio.get(
      '/admin/analysis-jobs/$jobId/articles',
      queryParameters: queryParams,
    );
    final items = response.data['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => JobArticleModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> retryFailedArticles(String jobId) async {
    await apiClient.dio.post('/admin/analysis-jobs/$jobId/retry');
  }
}
