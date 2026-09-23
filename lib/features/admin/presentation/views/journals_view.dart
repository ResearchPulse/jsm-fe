import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class JournalsView extends StatelessWidget {
  final Function(int) onNavigateToTab;
  final Function(String journalId)? onTriggerAnalyzeJournal;

  const JournalsView({
    super.key,
    required this.onNavigateToTab,
    this.onTriggerAnalyzeJournal,
  });

  void _showAddJournalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final issnController = TextEditingController();
    final domainController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Register journal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Manrope',
              color: AppColors.textPrimary,
            ),
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter the journal details to add it to the tracked catalog.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontFamily: 'Manrope'),
                ),
                const SizedBox(height: 20),
                const Text('Journal full title', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. IEEE Transactions on Software Engineering',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('ISSN / e-ISSN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                          const SizedBox(height: 6),
                          TextField(
                            controller: issnController,
                            decoration: const InputDecoration(
                              hintText: '0098-5589',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Domain', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                          const SizedBox(height: 6),
                          TextField(
                            controller: domainController,
                            decoration: const InputDecoration(
                              hintText: 'Software Engineering',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                    content: Text('Journal registered successfully.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Save journal'),
            ),
          ],
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
                    'Registry',
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
                  'Journal management',
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
                  'Register scientific journals with verified ISSNs to prepare automated harvesting configurations.',
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
                      Icon(Icons.inventory_2_outlined, size: 18, color: AppColors.textMuted),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No journal selected. Register a new journal to manage ISSN metadata and pipeline triggers.',
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
                      onPressed: () => _showAddJournalDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Register journal'),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => onNavigateToTab(2),
                      icon: const Icon(Icons.tune_outlined, size: 18),
                      label: const Text('View configurations'),
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
