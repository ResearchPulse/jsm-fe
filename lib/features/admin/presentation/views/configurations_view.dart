import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class ConfigurationsView extends StatelessWidget {
  final Function(int) onNavigateToTab;
  final VoidCallback? onTriggerNewAnalysis;

  const ConfigurationsView({
    super.key,
    required this.onNavigateToTab,
    this.onTriggerNewAnalysis,
  });

  void _showConfigDialog(BuildContext context) {
    int yearStart = 2021;
    int yearEnd = 2024;
    double targetPapers = 200;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Create configuration',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  color: AppColors.textPrimary,
                ),
              ),
              content: SizedBox(
                width: 480,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Define sampling thresholds and baseline corpus for pipeline execution.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontFamily: 'Manrope'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Target journal ISSN or title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                    const SizedBox(height: 6),
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter journal name or ISSN...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start year', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                value: yearStart,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                                items: [2018, 2019, 2020, 2021, 2022].map((y) {
                                  return DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(fontFamily: 'Manrope')));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => yearStart = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End year', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                value: yearEnd,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                                items: [2023, 2024, 2025].map((y) {
                                  return DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(fontFamily: 'Manrope')));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => yearEnd = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Target paper sample count', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                        Text(
                          '${targetPapers.toInt()} papers',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Manrope'),
                        ),
                      ],
                    ),
                    Slider(
                      value: targetPapers,
                      min: 50,
                      max: 500,
                      divisions: 9,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => targetPapers = val),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuration saved successfully.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Save configuration'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink900.withAlpha(8),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Pipeline setup',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Journal configurations',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),

                const Text(
                  'Define publication year ranges, sampling target thresholds, and comparative reference baselines.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted,
                    fontFamily: 'Manrope',
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.tune_rounded, size: 18, color: AppColors.textMuted),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Configure a journal with year bounds and sample target to initialize automated feature extraction.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _showConfigDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Create configuration'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => onNavigateToTab(3),
                      icon: const Icon(Icons.sync_rounded, size: 18),
                      label: const Text('Monitor pipeline'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
