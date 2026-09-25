import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/voice_person_comparison.dart';

class VoicePersonCard extends StatelessWidget {
  final VoicePersonComparison? comparison;

  const VoicePersonCard({
    super.key,
    required this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    if (comparison == null) return const SizedBox.shrink();

    final comp = comparison!;
    final passiveDiff = comp.passiveRateDiff;
    final weDiff = comp.weRateDiff;

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
            children: const [
              Icon(
                Icons.record_voice_over_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Voice & Person Comparison',
                  style: TextStyle(
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
                child: _ComparisonTile(
                  title: 'Passive Voice Rate',
                  userValue: '${(comp.userPassiveRate * 100).toStringAsFixed(1)}%',
                  journalValue:
                      '${(comp.journalPassiveRate * 100).toStringAsFixed(1)}%',
                  diff: passiveDiff,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ComparisonTile(
                  title: '“We” / Author Voice Rate',
                  userValue: '${(comp.userWeRate * 100).toStringAsFixed(1)}%',
                  journalValue:
                      '${(comp.journalWeRate * 100).toStringAsFixed(1)}%',
                  diff: weDiff,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ComparisonTile extends StatelessWidget {
  final String title;
  final String userValue;
  final String journalValue;
  final double diff;

  const _ComparisonTile({
    required this.title,
    required this.userValue,
    required this.journalValue,
    required this.diff,
  });

  @override
  Widget build(BuildContext context) {
    final absDiff = diff.abs() * 100;
    final isAlighed = absDiff <= 15.0;

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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isAlighed ? AppColors.green50 : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isAlighed
                  ? 'Consistent with journal'
                  : '${diff > 0 ? "+" : ""}${(diff * 100).toStringAsFixed(1)}% difference',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isAlighed ? AppColors.green700 : const Color(0xFFB45309),
                fontFamily: 'Manrope',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
