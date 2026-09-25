import 'package:equatable/equatable.dart';

/// Stance features comparison (hedges, boosters per 1,000 words).
class StanceComparison extends Equatable {
  final double userHedgeRate;
  final double journalHedgeRate;
  final double userBoosterRate;
  final double journalBoosterRate;

  const StanceComparison({
    required this.userHedgeRate,
    required this.journalHedgeRate,
    required this.userBoosterRate,
    required this.journalBoosterRate,
  });

  double get hedgeRateDiff => userHedgeRate - journalHedgeRate;
  double get boosterRateDiff => userBoosterRate - journalBoosterRate;

  factory StanceComparison.fromMap(Map<String, dynamic> map) {
    return StanceComparison(
      userHedgeRate:
          (map['user_hedge_rate_per_1k'] as num?)?.toDouble() ?? 0.0,
      journalHedgeRate:
          (map['journal_hedge_rate_per_1k'] as num?)?.toDouble() ?? 0.0,
      userBoosterRate:
          (map['user_booster_rate_per_1k'] as num?)?.toDouble() ?? 0.0,
      journalBoosterRate:
          (map['journal_booster_rate_per_1k'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_hedge_rate_per_1k': userHedgeRate,
      'journal_hedge_rate_per_1k': journalHedgeRate,
      'user_booster_rate_per_1k': userBoosterRate,
      'journal_booster_rate_per_1k': journalBoosterRate,
    };
  }

  @override
  List<Object?> get props => [
        userHedgeRate,
        journalHedgeRate,
        userBoosterRate,
        journalBoosterRate,
      ];
}
