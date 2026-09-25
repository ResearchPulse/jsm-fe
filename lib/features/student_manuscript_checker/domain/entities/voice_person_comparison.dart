import 'package:equatable/equatable.dart';

/// Voice and person metrics comparison (passive voice, we/author person usage).
class VoicePersonComparison extends Equatable {
  final double userPassiveRate;
  final double journalPassiveRate;
  final double userWeRate;
  final double journalWeRate;

  const VoicePersonComparison({
    required this.userPassiveRate,
    required this.journalPassiveRate,
    required this.userWeRate,
    required this.journalWeRate,
  });

  double get passiveRateDiff => userPassiveRate - journalPassiveRate;
  double get weRateDiff => userWeRate - journalWeRate;

  factory VoicePersonComparison.fromMap(Map<String, dynamic> map) {
    return VoicePersonComparison(
      userPassiveRate: (map['user_passive_rate'] as num?)?.toDouble() ?? 0.0,
      journalPassiveRate:
          (map['journal_passive_rate'] as num?)?.toDouble() ?? 0.0,
      userWeRate: (map['user_we_rate'] as num?)?.toDouble() ?? 0.0,
      journalWeRate: (map['journal_we_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_passive_rate': userPassiveRate,
      'journal_passive_rate': journalPassiveRate,
      'user_we_rate': userWeRate,
      'journal_we_rate': journalWeRate,
    };
  }

  @override
  List<Object?> get props => [
        userPassiveRate,
        journalPassiveRate,
        userWeRate,
        journalWeRate,
      ];
}
