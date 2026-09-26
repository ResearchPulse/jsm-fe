import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/stance_comparison.dart';
import '../../../../core/localization/app_localizations.dart';

class StanceCard extends StatelessWidget {
  final StanceComparison? comparison;

  const StanceCard({
    super.key,
    required this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    if (comparison == null) return const SizedBox.shrink();

    final comp = comparison!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.l10n.stanceAnalysis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StanceMetricTile(
                  title: context.l10n.hedgesRate,
                  subtitle: 'E.g., "suggests", "may indicate"',
                  userValue:
                      '${comp.userHedgeRate.toStringAsFixed(1)} ${context.l10n.per1kWords}',
                  journalValue:
                      '${comp.journalHedgeRate.toStringAsFixed(1)} ${context.l10n.per1kWords}',
                  diff: comp.hedgeRateDiff,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StanceMetricTile(
                  title: context.l10n.boostersRate,
                  subtitle: 'E.g., "clearly shows", "definitely"',
                  userValue:
                      '${comp.userBoosterRate.toStringAsFixed(1)} ${context.l10n.per1kWords}',
                  journalValue:
                      '${comp.journalBoosterRate.toStringAsFixed(1)} ${context.l10n.per1kWords}',
                  diff: comp.boosterRateDiff,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StanceMetricTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String userValue;
  final String journalValue;
  final double diff;

  const _StanceMetricTile({
    required this.title,
    required this.subtitle,
    required this.userValue,
    required this.journalValue,
    required this.diff,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Manrope',
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSubtle,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MANUSCRIPT',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSubtle,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    userValue,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'JOURNAL',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSubtle,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    journalValue,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
