import 'package:equatable/equatable.dart';

class JournalConfigurationModel extends Equatable {
  final String id;
  final String journalId;
  final String domain;
  final int yearFrom;
  final int yearTo;
  final int targetArticles;
  final String? referenceCorpusName;
  final bool isActive;
  final String? journalTitle;
  final String? journalIssn;

  const JournalConfigurationModel({
    required this.id,
    required this.journalId,
    required this.domain,
    required this.yearFrom,
    required this.yearTo,
    required this.targetArticles,
    this.referenceCorpusName,
    this.isActive = true,
    this.journalTitle,
    this.journalIssn,
  });

  factory JournalConfigurationModel.fromJson(Map<String, dynamic> json) {
    final journal = json['journal'] as Map<String, dynamic>?;
    return JournalConfigurationModel(
      id: json['id'] as String,
      journalId: json['journal_id'] as String,
      domain: json['domain'] as String? ?? 'Software Engineering',
      yearFrom: (json['year_from'] as num?)?.toInt() ?? 2021,
      yearTo: (json['year_to'] as num?)?.toInt() ?? 2025,
      targetArticles: (json['target_articles'] as num?)?.toInt() ?? 300,
      referenceCorpusName: json['reference_corpus_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      journalTitle: journal?['title'] as String?,
      journalIssn: journal?['issn_l'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, journalId, domain, yearFrom, yearTo, targetArticles];
}
