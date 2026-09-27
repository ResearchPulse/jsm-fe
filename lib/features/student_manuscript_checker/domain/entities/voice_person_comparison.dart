import 'dart:developer' as developer;
import 'package:equatable/equatable.dart';

/// Voice and person metrics comparison (passive voice, we/author person usage).
///
/// All rates represent percentages between 0.0% and 100.0% (e.g., 20.0 = 20.0%, 31.2 = 31.2%).
/// Differences represent percentage points (pp).
class VoicePersonComparison extends Equatable {
  final double userPassiveRate;
  final double journalPassiveRate;
  final double userWeRate;
  final double journalWeRate;
  final String unit;

  const VoicePersonComparison({
    required this.userPassiveRate,
    required this.journalPassiveRate,
    required this.userWeRate,
    required this.journalWeRate,
    this.unit = '%',
  });

  /// Difference in percentage points (pp) between manuscript and journal passive voice rate.
  double get passiveRateDiff => userPassiveRate - journalPassiveRate;

  /// Difference in percentage points (pp) between manuscript and journal author person rate.
  double get weRateDiff => userWeRate - journalWeRate;

  factory VoicePersonComparison.fromMap(Map<String, dynamic> map) {
    final userPassive = (map['user_passive_rate'] as num?)?.toDouble() ?? 0.0;
    final journalPassive =
        (map['journal_passive_rate'] as num?)?.toDouble() ?? 0.0;
    final userWe = (map['user_we_rate'] as num?)?.toDouble() ?? 0.0;
    final journalWe = (map['journal_we_rate'] as num?)?.toDouble() ?? 0.0;

    // Development-time safety validation for percentage metrics (expected 0.0 - 100.0)
    assert(() {
      if (userPassive < 0.0 || userPassive > 100.0) {
        developer.log(
          'Suspicious user_passive_rate: $userPassive%. Expected 0.0-100.0%',
          name: 'VoicePersonComparison',
        );
      }
      if (journalPassive < 0.0 || journalPassive > 100.0) {
        developer.log(
          'Suspicious journal_passive_rate: $journalPassive%. Expected 0.0-100.0%',
          name: 'VoicePersonComparison',
        );
      }
      if (userWe < 0.0 || userWe > 100.0) {
        developer.log(
          'Suspicious user_we_rate: $userWe%. Expected 0.0-100.0%',
          name: 'VoicePersonComparison',
        );
      }
      if (journalWe < 0.0 || journalWe > 100.0) {
        developer.log(
          'Suspicious journal_we_rate: $journalWe%. Expected 0.0-100.0%',
          name: 'VoicePersonComparison',
        );
      }
      return true;
    }());

    return VoicePersonComparison(
      userPassiveRate: userPassive,
      journalPassiveRate: journalPassive,
      userWeRate: userWe,
      journalWeRate: journalWe,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_passive_rate': userPassiveRate,
      'journal_passive_rate': journalPassiveRate,
      'user_we_rate': userWeRate,
      'journal_we_rate': journalWeRate,
      'unit': unit,
    };
  }

  @override
  List<Object?> get props => [
        userPassiveRate,
        journalPassiveRate,
        userWeRate,
        journalWeRate,
        unit,
      ];
}
