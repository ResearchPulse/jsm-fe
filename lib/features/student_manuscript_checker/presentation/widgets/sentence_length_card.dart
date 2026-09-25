import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/sentence_length_comparison.dart';

class SentenceLengthCard extends StatelessWidget {
  final SentenceLengthComparison? comparison;

  const SentenceLengthCard({
    super.key,
    required this.comparison,
  });

  @override
  Widget build(BuildContext context) {
    if (comparison == null) return const SizedBox.shrink();

    final comp = comparison!;
    final isWithin = comp.isWithinRange;
    final statusColor = isWithin
        ? AppColors.green700
        : comp.isTooShort
            ? const Color(0xFFD97706)
            : AppColors.red700;
    final statusBg = isWithin
        ? AppColors.green50
        : comp.isTooShort
            ? const Color(0xFFFFFBEB)
            : AppColors.red50;

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
                Icons.short_text_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Sentence Length Analysis',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  comp.statusDisplayLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
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
                child: _MetricTile(
                  label: 'MANUSCRIPT MEDIAN',
                  value: '${comp.userMedian.toStringAsFixed(1)} words',
                  highlightColor: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'JOURNAL MEDIAN',
                  value: '${comp.journalMedian.toStringAsFixed(1)} words',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(
                  label: 'EXPECTED P10 - P90',
                  value:
                      '${comp.journalP10.toStringAsFixed(0)} - ${comp.journalP90.toStringAsFixed(0)} words',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Academic journals favor concise, focused sentences. Sentences exceeding the P90 threshold increase reading friction, while sentences below P10 may lack depth.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
              fontFamily: 'Manrope',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? highlightColor;

  const _MetricTile({
    required this.label,
    required this.value,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSubtle,
              letterSpacing: 0.3,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: highlightColor ?? AppColors.textPrimary,
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ),
    );
  }
}
