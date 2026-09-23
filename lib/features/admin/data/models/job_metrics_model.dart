import 'package:equatable/equatable.dart';

class JobMetricsModel extends Equatable {
  final int totalArticles;
  final int harvested;
  final int fetched;
  final int parsed;
  final int normalized;
  final int failed;

  const JobMetricsModel({
    this.totalArticles = 0,
    this.harvested = 0,
    this.fetched = 0,
    this.parsed = 0,
    this.normalized = 0,
    this.failed = 0,
  });

  factory JobMetricsModel.fromJson(Map<String, dynamic> json) {
    return JobMetricsModel(
      totalArticles: json['total_articles'] as int? ?? 0,
      harvested: json['harvested'] as int? ?? 0,
      fetched: json['fetched'] as int? ?? 0,
      parsed: json['parsed'] as int? ?? 0,
      normalized: json['normalized'] as int? ?? 0,
      failed: json['failed'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        totalArticles,
        harvested,
        fetched,
        parsed,
        normalized,
        failed,
      ];
}
