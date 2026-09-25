import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/warning_item.dart';

class WarningsListCard extends StatelessWidget {
  final List<WarningItem> warnings;

  const WarningsListCard({
    super.key,
    required this.warnings,
  });

  Color _severityColor(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.red700;
      case 'HIGH':
        return const Color(0xFFEA580C); // Deep Orange
      case 'MEDIUM':
        return const Color(0xFFD97706); // Warm Amber
      case 'LOW':
        return AppColors.blue600;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _severityBg(String severity) {
    switch (severity.toUpperCase()) {
      case 'CRITICAL':
        return AppColors.red50;
      case 'HIGH':
        return const Color(0xFFFFF7ED);
      case 'MEDIUM':
        return const Color(0xFFFFFBEB);
      case 'LOW':
        return AppColors.blue50;
      default:
        return AppColors.surfaceSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (warnings.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(24),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.green700, size: 20),
              SizedBox(width: 8),
              Text(
                'No style warnings detected. Manuscript aligns well with target journal.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.green700,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                Icons.warning_amber_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Diagnostics & Style Warnings',
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
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${warnings.length} items',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    fontFamily: 'Manrope',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: warnings.map((w) {
              final color = _severityColor(w.severity);
              final bg = _severityBg(w.severity);
              final exemplar = w.exemplar;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: color.withAlpha(50)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            w.severity.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ),
                        if (w.section.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.borderSoft),
                            ),
                            child: Text(
                              w.section.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontFamily: 'Manrope',
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Text(
                          w.id,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      w.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      w.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontFamily: 'Manrope',
                        height: 1.4,
                      ),
                    ),

                    // Optional Validated Exemplar
                    if (exemplar != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.format_quote_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    'Validated Exemplar from Target Journal',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      fontFamily: 'Manrope',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (exemplar.doi != null &&
                                    exemplar.doi!.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'DOI: ${exemplar.doi}',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '“${exemplar.text}”',
                              style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textPrimary,
                                fontFamily: 'Manrope',
                                height: 1.4,
                              ),
                            ),
                            if (exemplar.articleTitle != null &&
                                exemplar.articleTitle!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Source: ${exemplar.articleTitle}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSubtle,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
