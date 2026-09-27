import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/journal_recommendation_item.dart';

class RecommendationsDimensionTable extends StatelessWidget {
  final List<JournalRecommendationItem> recommendations;

  const RecommendationsDimensionTable({
    super.key,
    required this.recommendations,
  });

  Color _getCellBgColor(double score) {
    if (score >= 80) return AppColors.successSurface;
    if (score >= 60) return AppColors.warningSurface;
    return AppColors.errorSurface;
  }

  Color _getCellTextColor(double score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    final dimensions = [
      (
        'Structure Alignment',
        (JournalRecommendationItem r) => r.dimensions.structure,
      ),
      (
        'Sentence Style',
        (JournalRecommendationItem r) => r.dimensions.sentenceStyle,
      ),
      (
        'Voice & Person',
        (JournalRecommendationItem r) => r.dimensions.voiceAndPerson,
      ),
      (
        'Epistemic Style',
        (JournalRecommendationItem r) => r.dimensions.epistemicStyle,
      ),
      (
        'Rhetorical Moves',
        (JournalRecommendationItem r) => r.dimensions.rhetoricalMoves,
      ),
      ('Overall Match', (JournalRecommendationItem r) => r.compatibilityScore),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.grid_view_rounded, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Cross-Journal Dimension Comparison Heatmap',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder.all(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(8),
                width: 1,
              ),
              children: [
                // Header row
                TableRow(
                  decoration: const BoxDecoration(color: AppColors.surfaceSoft),
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        'Dimension',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                    ...recommendations.map(
                      (rec) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              rec.journalName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontFamily: 'Manrope',
                              ),
                            ),
                            Text(
                              '#${rec.rank}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Data rows
                ...dimensions.map((dim) {
                  final isOverall = dim.$1 == 'Overall Match';
                  return TableRow(
                    decoration: BoxDecoration(
                      color: isOverall
                          ? AppColors.primarySoft.withValues(alpha: 0.3)
                          : Colors.transparent,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          dim.$1,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isOverall
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isOverall
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      ...recommendations.map((rec) {
                        final score = dim.$2(rec);
                        final bg = _getCellBgColor(score);
                        final textClr = _getCellTextColor(score);
                        return Container(
                          color: isOverall ? null : bg,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${score.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isOverall
                                  ? FontWeight.w800
                                  : FontWeight.w700,
                              color: isOverall ? AppColors.primary : textClr,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem(
                '≥80% Strong',
                AppColors.success,
                AppColors.successSurface,
              ),
              const SizedBox(width: 12),
              _buildLegendItem(
                '60–79% Moderate',
                AppColors.warning,
                AppColors.warningSurface,
              ),
              const SizedBox(width: 12),
              _buildLegendItem(
                '<60% Low',
                AppColors.error,
                AppColors.errorSurface,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color textColor, Color bgColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: textColor.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
