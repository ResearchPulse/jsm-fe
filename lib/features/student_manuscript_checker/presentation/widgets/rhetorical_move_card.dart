import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/warning_item.dart';
import '../../../../core/localization/app_localizations.dart';

class RhetoricalMoveCard extends StatelessWidget {
  final List<WarningItem> moveWarnings;
  final int totalSections;

  const RhetoricalMoveCard({
    super.key,
    required this.moveWarnings,
    required this.totalSections,
  });

  @override
  Widget build(BuildContext context) {
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
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_tree_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.rhetoricalMovesTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: moveWarnings.isEmpty
                      ? AppColors.green50
                      : AppColors.red50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  moveWarnings.isEmpty
                      ? 'All Moves Satisfied'
                      : '${moveWarnings.length} Missing Moves Detected',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: moveWarnings.isEmpty
                        ? AppColors.green700
                        : AppColors.red700,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (moveWarnings.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.green50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: AppColors.green700, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'The manuscript contains the essential rhetorical moves (Problem Framing, Contribution, Methodology) expected by the journal.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.green700,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Column(
              children: moveWarnings.map((warning) {
                final isGap = warning.isGapWarning;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isGap ? AppColors.red50 : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: isGap
                        ? Border.all(color: AppColors.red100)
                        : Border.all(color: AppColors.borderSoft),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isGap
                            ? Icons.error_outline_rounded
                            : Icons.warning_amber_rounded,
                        size: 16,
                        color: isGap ? AppColors.red700 : const Color(0xFFD97706),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  warning.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isGap
                                        ? AppColors.red700
                                        : AppColors.textPrimary,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                                if (warning.section.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      warning.section,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMuted,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              warning.message,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontFamily: 'Manrope',
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
