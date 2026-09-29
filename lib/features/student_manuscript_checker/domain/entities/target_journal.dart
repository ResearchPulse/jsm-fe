import 'package:equatable/equatable.dart';

/// Representation of a target journal in the system that can be selected for benchmarking.
class TargetJournal extends Equatable {
  final String id;
  final String title;
  final String? openAlexId;
  final String? domain;
  final String? issn;

  const TargetJournal({
    required this.id,
    required this.title,
    this.openAlexId,
    this.domain,
    this.issn,
  });

  factory TargetJournal.fromMap(Map<String, dynamic> map) {
    return TargetJournal(
      id: '${map['id'] ?? ''}',
      title: map['title'] as String? ?? 'Unnamed Journal',
      openAlexId: map['openalex_id'] as String?,
      domain: map['domain'] as String?,
      issn: map['issn_l'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'openalex_id': openAlexId,
      'domain': domain,
      'issn_l': issn,
    };
  }

  @override
  List<Object?> get props => [id, title, openAlexId, domain, issn];
}
