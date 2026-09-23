import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class OverviewView extends StatelessWidget {
  final Function(int) onNavigateToTab;
  final VoidCallback onTriggerNewAnalysis;

  const OverviewView({
    super.key,
    required this.onNavigateToTab,
    required this.onTriggerNewAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Focused Panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24), // --ds-radius-panel
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
                    // Header label
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blue50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Không gian giảng viên',
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
                      'Bản Thảo Của Tôi',
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
                      'Quản lý danh sách bản thảo nghiên cứu, kiểm tra độ lệch phong cách và đối chiếu bằng chứng học thuật.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textMuted,
                        fontFamily: 'Manrope',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Status Message Component (per Design System section 5.5)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(10), // --ds-radius-control
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textMuted),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Hệ thống sẵn sàng. Bạn có thể tải lên bản thảo mới (.docx, .pdf) để thẩm định phong cách.',
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

                    // Primary confident action
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: onTriggerNewAnalysis,
                          icon: const Icon(Icons.upload_file_rounded, size: 18),
                          label: const Text('Tải bản thảo lên'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: () => onNavigateToTab(2),
                          icon: const Icon(Icons.tune_outlined, size: 18),
                          label: const Text('Cấu hình tạp chí'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Navigation Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildQuickCard(
                      title: 'Journal management',
                      description: 'Browse registered journals, ISSNs, and domain classifications.',
                      icon: Icons.menu_book_outlined,
                      onTap: () => onNavigateToTab(1),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildQuickCard(
                      title: 'Corpus snapshots',
                      description: 'Review immutable snapshot collections and reference baselines.',
                      icon: Icons.layers_outlined,
                      onTap: () => onNavigateToTab(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCard({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontFamily: 'Manrope',
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
