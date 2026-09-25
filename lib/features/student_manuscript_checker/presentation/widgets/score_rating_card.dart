import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/manuscript_check_result.dart';

class ScoreRatingCard extends StatelessWidget {
  final ManuscriptCheckResult result;
  final String? journalTitle;
  final String? filename;

  const ScoreRatingCard({
    super.key,
    required this.result,
    this.journalTitle,
    this.filename,
  });

  Color _getRatingColor() {
    if (result.isExcellent) return AppColors.green700;
    if (result.isModerate) return const Color(0xFFD97706); // Warm Amber
    return AppColors.red700;
  }

  Color _getRatingBackground() {
    if (result.isExcellent) return AppColors.green50;
    if (result.isModerate) return const Color(0xFFFFFBEB);
    return AppColors.red50;
  }

  Color _getRatingBorder() {
    if (result.isExcellent) return AppColors.green100;
    if (result.isModerate) return const Color(0xFFFDE68A);
    return AppColors.red100;
  }

  IconData _getRatingIcon() {
    if (result.isExcellent) return Icons.verified_rounded;
    if (result.isModerate) return Icons.info_outline_rounded;
    return Icons.warning_amber_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final ratingColor = _getRatingColor();
    final ratingBg = _getRatingBackground();
    final ratingBorder = _getRatingBorder();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Manuscript info & metadata
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.article_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            filename ?? 'Student Manuscript',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Manrope',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (journalTitle != null && journalTitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.tune_rounded,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Target Profile: $journalTitle',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontFamily: 'Manrope',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Rating Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: ratingBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ratingBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getRatingIcon(), size: 16, color: ratingColor),
                    const SizedBox(width: 6),
                    Text(
                      result.ratingLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ratingColor,
                        fontFamily: 'Manrope',
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: AppColors.borderSoft),
          const SizedBox(height: 20),

          // Main Score & Summary Area
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Deterministic score circle
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ratingBg,
                  border: Border.all(color: ratingBorder, width: 2),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      result.suitabilityScore.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: ratingColor,
                        fontFamily: 'Manrope',
                        letterSpacing: -0.5,
                      ),
                    ),
                    const Text(
                      'OUT OF 100',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSubtle,
                        letterSpacing: 0.5,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Summary text & section scores count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Suitability Assessment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.summary,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontFamily: 'Manrope',
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _StatChip(
                          icon: Icons.view_headline_rounded,
                          label: '${result.sectionScores.length} Sections Evaluated',
                        ),
                        _StatChip(
                          icon: Icons.warning_amber_rounded,
                          label: '${result.warnings.length} Warnings Generated',
                          isAlert: result.warnings.isNotEmpty,
                        ),
                        if (result.hasMissingGap)
                          const _StatChip(
                            icon: Icons.report_problem_rounded,
                            label: 'Missing Research Gap',
                            isCritical: true,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAlert;
  final bool isCritical;

  const _StatChip({
    required this.icon,
    required this.label,
    this.isAlert = false,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.surfaceSoft;
    Color fg = AppColors.textSecondary;

    if (isCritical) {
      bg = AppColors.red50;
      fg = AppColors.red700;
    } else if (isAlert) {
      bg = const Color(0xFFFFFBEB);
      fg = const Color(0xFFB45309);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ),
    );
  }
}
