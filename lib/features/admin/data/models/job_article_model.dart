import 'package:equatable/equatable.dart';

class JobArticleModel extends Equatable {
  final String id;
  final String jobId;
  final String journalId;
  final String doi;
  final String title;
  final int? year;
  final String? volume;
  final String? issue;
  final String articleType;
  final String? license;
  final String? oaUrl;
  final String status;
  final String? rawStoragePath;
  final String? checksum;
  final String? errorMessage;
  final int retryCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const JobArticleModel({
    required this.id,
    required this.jobId,
    required this.journalId,
    required this.doi,
    required this.title,
    this.year,
    this.volume,
    this.issue,
    this.articleType = 'article',
    this.license,
    this.oaUrl,
    required this.status,
    this.rawStoragePath,
    this.checksum,
    this.errorMessage,
    this.retryCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory JobArticleModel.fromJson(Map<String, dynamic> json) {
    return JobArticleModel(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      journalId: json['journal_id'] as String,
      doi: json['doi'] as String? ?? '',
      title: json['title'] as String? ?? '',
      year: json['year'] as int?,
      volume: json['volume'] as String?,
      issue: json['issue'] as String?,
      articleType: json['article_type'] as String? ?? 'article',
      license: json['license'] as String?,
      oaUrl: json['oa_url'] as String?,
      status: json['status'] as String? ?? 'HARVESTED',
      rawStoragePath: json['raw_storage_path'] as String?,
      checksum: json['checksum'] as String?,
      errorMessage: json['error_message'] as String?,
      retryCount: json['retry_count'] as int? ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        jobId,
        doi,
        title,
        status,
        retryCount,
        errorMessage,
      ];
}
