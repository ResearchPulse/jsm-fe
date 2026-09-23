import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/models/openalex_journal_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class ConfigurationsView extends StatefulWidget {
  final Function(int) onNavigateToTab;
  final VoidCallback? onTriggerNewAnalysis;

  const ConfigurationsView({
    super.key,
    required this.onNavigateToTab,
    this.onTriggerNewAnalysis,
  });

  @override
  State<ConfigurationsView> createState() => _ConfigurationsViewState();
}

class _ConfigurationsViewState extends State<ConfigurationsView> {
  final _domainController = TextEditingController(text: 'Software Engineering');
  final _referenceCorpusController = TextEditingController(
      text: 'Other Software Engineering Journals');

  int _yearStart = 2021;
  int _yearEnd = 2025;
  double _targetPapers = 300;

  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().loadConfigurations();
  }

  @override
  void dispose() {
    _domainController.dispose();
    _referenceCorpusController.dispose();
    super.dispose();
  }

  Future<void> _submitAndAnalyze(OpenAlexJournalModel journal) async {
    final cubit = context.read<AdminCubit>();
    final success = await cubit.createConfigurationAndAnalyze(
      journal: journal,
      domain: _domainController.text.trim().isEmpty
          ? 'Software Engineering'
          : _domainController.text.trim(),
      yearFrom: _yearStart,
      yearTo: _yearEnd,
      targetArticles: _targetPapers.toInt(),
      referenceCorpusName: _referenceCorpusController.text.trim().isEmpty
          ? null
          : _referenceCorpusController.text.trim(),
    );

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã tạo cấu hình và kích hoạt tiến trình phân tích thành công!',
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onNavigateToTab(3); // Chuyển sang Job Monitor
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        final selectedJournal = state.selectedJournalForConfig;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Panel
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink900.withAlpha(8),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.blue50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Pipeline Sampling Configuration',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Manrope',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Cấu Hình Phân Tích Tạp Chí',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Manrope',
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Thiết lập ngưỡng lấy mẫu, khung thời gian và nhóm đối chiếu (Reference Corpus) để chuẩn bị cho tiến trình phân tích tự động.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            fontFamily: 'Manrope',
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Selected Journal Banner or Prompt
                  if (selectedJournal != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withAlpha(120), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.blue50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.bookmark_added_rounded,
                                    color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'TẠP CHÍ ĐANG ĐƯỢC CHỌN ĐỂ CẤU HÌNH:',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      selectedJournal.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                        fontFamily: 'Manrope',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => widget.onNavigateToTab(1),
                                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                                label: const Text('Đổi tạp chí khác'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            children: [
                              if (selectedJournal.issnL != null)
                                Text('ISSN: ${selectedJournal.issnL}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w500)),
                              if (selectedJournal.publisher != null)
                                Text('NXB: ${selectedJournal.publisher}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                        fontWeight: FontWeight.w500)),
                              Text('Quy mô: ${selectedJournal.worksCount} bài báo',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 20),

                          // Configuration Form Fields
                          const Text(
                            'Thông số khai thác:',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Lĩnh vực chuyên môn (Domain)',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _domainController,
                                      decoration: const InputDecoration(
                                        hintText: 'Software Engineering',
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Nhóm đối chiếu (Reference Corpus)',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _referenceCorpusController,
                                      decoration: const InputDecoration(
                                        hintText:
                                            'Other Software Engineering Journals',
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Năm bắt đầu (Year From)',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<int>(
                                      initialValue: _yearStart,
                                      decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10)),
                                      items: [2018, 2019, 2020, 2021, 2022]
                                          .map((y) => DropdownMenuItem(
                                              value: y, child: Text('$y')))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _yearStart = val);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Năm kết thúc (Year To)',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<int>(
                                      initialValue: _yearEnd,
                                      decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 10)),
                                      items: [2023, 2024, 2025, 2026]
                                          .map((y) => DropdownMenuItem(
                                              value: y, child: Text('$y')))
                                          .toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _yearEnd = val);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Số lượng bài báo mục tiêu (Target Papers)',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                              Text(
                                '${_targetPapers.toInt()} bài báo',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _targetPapers,
                            min: 50,
                            max: 500,
                            divisions: 9,
                            activeColor: AppColors.primary,
                            onChanged: (val) =>
                                setState(() => _targetPapers = val),
                          ),

                          const SizedBox(height: 24),

                          // Trigger Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: state.isTriggeringJob
                                  ? null
                                  : () => _submitAndAnalyze(selectedJournal),
                              icon: state.isTriggeringJob
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.rocket_launch_rounded,
                                      size: 18),
                              label: Text(
                                state.isTriggeringJob
                                    ? 'Đang khởi tạo tiến trình...'
                                    : '🚀 Bắt đầu phân tích (Start Analysis Job)',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Prompt to select from Tab 1
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.touch_app_outlined,
                              size: 44, color: AppColors.primary),
                          const SizedBox(height: 14),
                          const Text(
                            'Chưa chọn tạp chí để tạo cấu hình',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Vui lòng sang tab "Kho Bài Báo Khoa Học" để tìm kiếm và bấm nút "Cấu hình phân tích" cho một tạp chí.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => widget.onNavigateToTab(1),
                            icon: const Icon(Icons.search_rounded, size: 18),
                            label: const Text('Đến Kho Bài Báo Khoa Học'),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Existing Configurations Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Danh sách cấu hình đã lưu trong hệ thống',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Tải lại',
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        onPressed: () =>
                            context.read<AdminCubit>().loadConfigurations(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (state.isLoadingConfigs) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ] else if (state.configurations.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text(
                          'Chưa có cấu hình phân tích nào được lưu.',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.configurations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final config = state.configurations[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.blue50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.settings_suggest_rounded,
                                    color: AppColors.primary, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      config.journalTitle ?? 'Tạp chí đã cấu hình',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Domain: ${config.domain}  •  Giai đoạn: ${config.yearFrom}–${config.yearTo}  •  Mục tiêu: ${config.targetArticles} bài',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final cubit = context.read<AdminCubit>();
                                  final job = await cubit.dataSource
                                      .triggerAnalysis(config.id);
                                  await cubit.loadJobs();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Đã kích hoạt phân tích lại (Job: ${job.currentStep})'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    widget.onNavigateToTab(3);
                                  }
                                },
                                icon: const Icon(Icons.play_arrow_rounded,
                                    size: 16),
                                label: const Text('Phân tích lại'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
