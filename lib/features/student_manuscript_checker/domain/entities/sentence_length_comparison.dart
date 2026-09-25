import 'package:equatable/equatable.dart';

/// Sentence length metrics comparison between student manuscript and journal benchmark.
class SentenceLengthComparison extends Equatable {
  final double userMedian;
  final double journalMedian;
  final double journalP10;
  final double journalP90;
  final String status;

  const SentenceLengthComparison({
    required this.userMedian,
    required this.journalMedian,
    required this.journalP10,
    required this.journalP90,
    required this.status,
  });

  bool get isWithinRange => status == 'WITHIN_RANGE';
  bool get isTooShort => status == 'TOO_SHORT';
  bool get isTooLong => status == 'TOO_LONG';

  String get statusDisplayLabel {
    switch (status) {
      case 'WITHIN_RANGE':
        return 'Within Journal Range';
      case 'TOO_SHORT':
        return 'Shorter than Expected';
      case 'TOO_LONG':
        return 'Longer than Expected';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  factory SentenceLengthComparison.fromMap(Map<String, dynamic> map) {
    return SentenceLengthComparison(
      userMedian: (map['user_median'] as num?)?.toDouble() ?? 0.0,
      journalMedian: (map['journal_median'] as num?)?.toDouble() ?? 0.0,
      journalP10: (map['journal_p10'] as num?)?.toDouble() ?? 0.0,
      journalP90: (map['journal_p90'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? 'WITHIN_RANGE',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_median': userMedian,
      'journal_median': journalMedian,
      'journal_p10': journalP10,
      'journal_p90': journalP90,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        userMedian,
        journalMedian,
        journalP10,
        journalP90,
        status,
      ];
}
