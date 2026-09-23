import 'package:equatable/equatable.dart';

enum AnalysisStatus {
  notAnalyzed,
  analyzing,
  analyzed,
  failed,
}

class OpenAlexJournalModel extends Equatable {
  final String openalexId;
  final String title;
  final String? issnL;
  final List<String> issns;
  final String? publisher;
  final String? homepageUrl;
  final int worksCount;
  final int citedByCount;
  final AnalysisStatus analysisStatus;
  final bool isImported;
  final String? journalId;
  final bool hasConfiguration;
  final String? latestConfigurationId;
  final String? latestJobId;
  final String? latestJobStatus;

  const OpenAlexJournalModel({
    required this.openalexId,
    required this.title,
    this.issnL,
    this.issns = const [],
    this.publisher,
    this.homepageUrl,
    this.worksCount = 0,
    this.citedByCount = 0,
    this.analysisStatus = AnalysisStatus.notAnalyzed,
    this.isImported = false,
    this.journalId,
    this.hasConfiguration = false,
    this.latestConfigurationId,
    this.latestJobId,
    this.latestJobStatus,
  });

  factory OpenAlexJournalModel.fromJson(Map<String, dynamic> json) {
    AnalysisStatus status = AnalysisStatus.notAnalyzed;
    final statusStr = json['analysis_status'] as String? ?? 'NOT_ANALYZED';
    switch (statusStr) {
      case 'ANALYZING':
        status = AnalysisStatus.analyzing;
        break;
      case 'ANALYZED':
        status = AnalysisStatus.analyzed;
        break;
      case 'FAILED':
        status = AnalysisStatus.failed;
        break;
      default:
        status = AnalysisStatus.notAnalyzed;
    }

    return OpenAlexJournalModel(
      openalexId: json['openalex_id'] as String? ?? '',
      title: json['title'] as String? ?? 'Chưa đặt tên',
      issnL: json['issn_l'] as String?,
      issns: (json['issns'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      publisher: json['publisher'] as String?,
      homepageUrl: json['homepage_url'] as String?,
      worksCount: (json['works_count'] as num?)?.toInt() ?? 0,
      citedByCount: (json['cited_by_count'] as num?)?.toInt() ?? 0,
      analysisStatus: status,
      isImported: json['is_imported'] as bool? ?? false,
      journalId: json['journal_id'] as String?,
      hasConfiguration: json['has_configuration'] as bool? ?? false,
      latestConfigurationId: json['latest_configuration_id'] as String?,
      latestJobId: json['latest_job_id'] as String?,
      latestJobStatus: json['latest_job_status'] as String?,
    );
  }

  Map<String, dynamic> toImportJson() {
    return {
      'openalex_id': openalexId,
      'title': title,
      'issn_l': issnL,
      'issns': issns,
      'publisher': publisher,
      'homepage_url': homepageUrl,
      'works_count': worksCount,
      'cited_by_count': citedByCount,
    };
  }

  @override
  List<Object?> get props => [
        openalexId,
        title,
        issnL,
        analysisStatus,
        isImported,
        hasConfiguration,
        latestJobId,
      ];
}

class OpenAlexPaginatedResult extends Equatable {
  final List<OpenAlexJournalModel> items;
  final int totalCount;
  final int page;
  final int perPage;

  const OpenAlexPaginatedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.perPage,
  });

  int get totalPages => perPage > 0 ? (totalCount / perPage).ceil() : 0;

  @override
  List<Object?> get props => [items, totalCount, page, perPage];
}

