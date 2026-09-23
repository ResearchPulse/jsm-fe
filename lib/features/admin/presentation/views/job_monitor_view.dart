import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/models/analysis_job_model.dart';
import '../../data/models/job_article_model.dart';
import '../../data/models/job_metrics_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class JobMonitorView extends StatefulWidget {
  final Function(int) onNavigateToTab;
  final VoidCallback? onTriggerNewAnalysis;

  const JobMonitorView({
    super.key,
    required this.onNavigateToTab,
    this.onTriggerNewAnalysis,
  });

  @override
  State<JobMonitorView> createState() => _JobMonitorViewState();
}

class _JobMonitorViewState extends State<JobMonitorView> {
  @override
  void initState() {
    super.initState();
    context.read<AdminCubit>().loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action / Notification Banner if any
                  if (state.actionMessage != null) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.blue50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              state.actionMessage!,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Header Card
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.blue50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Pipeline Execution Queue',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'Làm mới danh sách Jobs',
                              icon: const Icon(Icons.refresh_rounded, size: 20),
                              onPressed: () {
                                context.read<AdminCubit>().loadJobs();
                                if (state.selectedJobId != null) {
                                  context.read<AdminCubit>().loadJobDetails(state.selectedJobId!);
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Hàng Đợi & Giám Sát Tiến Trình (Analysis Job Monitor)',
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
                          'Theo dõi trạng thái và tiến độ từng bài báo khoa học qua 5 giai đoạn: Harvest, Fetch, GROBID Parse, Normalization, và Profile Synthesis.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            fontFamily: 'Manrope',
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Pipeline Stages Bar
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSoft,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chuỗi công đoạn Pipeline (Architecture Sequence):',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: const [
                                  _PipelineChip(
                                      label: '1. Harvest',
                                      desc: 'OpenAlex Works'),
                                  _PipelineChip(
                                      label: '2. Fetch',
                                      desc: 'Download & MinIO'),
                                  _PipelineChip(
                                      label: '3. Parse',
                                      desc: 'GROBID TEI-XML'),
                                  _PipelineChip(
                                      label: '4. Normalize',
                                      desc: '7-section clean'),
                                  _PipelineChip(
                                      label: '5. Hand-off',
                                      desc: 'Member 3 NLP'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Jobs Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh sách các lượt chạy phân tích (${state.jobs.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => widget.onNavigateToTab(2),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Cấu hình lượt chạy mới'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (state.isLoadingJobs) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ] else if (state.jobs.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.hourglass_empty_rounded,
                              size: 40, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'Chưa có tiến trình phân tích nào được kích hoạt.',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.jobs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final job = state.jobs[index];
                        final isSelected = state.selectedJobId == job.id;

                        return _JobCard(
                          job: job,
                          isSelected: isSelected,
                          metrics: isSelected ? state.selectedJobMetrics : null,
                          articles: isSelected ? state.selectedJobArticles : const [],
                          isLoadingDetails: isSelected && state.isLoadingJobDetails,
                          isRetrying: isSelected && state.isRetryingJob,
                          onToggleExpand: () {
                            final cubit = context.read<AdminCubit>();
                            if (isSelected) {
                              cubit.clearSelectedJob();
                            } else {
                              cubit.selectJob(job.id);
                            }
                          },
                          onRetryFailed: () {
                            context.read<AdminCubit>().retryJobArticles(job.id);
                          },
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

class _JobCard extends StatelessWidget {
  final AnalysisJobModel job;
  final bool isSelected;
  final JobMetricsModel? metrics;
  final List<JobArticleModel> articles;
  final bool isLoadingDetails;
  final bool isRetrying;
  final VoidCallback onToggleExpand;
  final VoidCallback onRetryFailed;

  const _JobCard({
    required this.job,
    required this.isSelected,
    required this.metrics,
    required this.articles,
    required this.isLoadingDetails,
    required this.isRetrying,
    required this.onToggleExpand,
    required this.onRetryFailed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withAlpha(isSelected ? 10 : 4),
            blurRadius: isSelected ? 14 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Summary Row
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.journalTitle ?? 'Tạp chí đang phân tích',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontFamily: 'Manrope',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Job ID: ${job.id}  •  Bước hiện tại: ${job.currentStep}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(job.status),
                      const SizedBox(width: 8),
                      Icon(
                        isSelected
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: job.status == 'COMPLETED'
                                ? 1.0
                                : (job.progress > 0 ? job.progress / 100 : null),
                            backgroundColor: AppColors.surfaceSoft,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              job.status == 'COMPLETED'
                                  ? Colors.green
                                  : AppColors.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        job.status == 'COMPLETED'
                            ? '100%'
                            : '${job.progress.toInt()}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Expanded Details Section
          if (isSelected) ...[
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stage Metrics Row
                  if (metrics != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tiến độ chi tiết từng công đoạn:',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (metrics!.failed > 0)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            onPressed: isRetrying ? null : onRetryFailed,
                            icon: isRetrying
                                ? const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 14),
                            label: Text(
                              isRetrying
                                  ? 'Đang thử lại...'
                                  : 'Thử lại ${metrics!.failed} bài lỗi',
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _MetricStatCard(
                          title: 'Tổng số bài',
                          count: metrics!.totalArticles,
                          color: Colors.blueGrey,
                          icon: Icons.library_books_rounded,
                        ),
                        _MetricStatCard(
                          title: '1. Harvested',
                          count: metrics!.harvested,
                          color: Colors.blue,
                          icon: Icons.grain_rounded,
                        ),
                        _MetricStatCard(
                          title: '2. Fetched',
                          count: metrics!.fetched,
                          color: Colors.purple,
                          icon: Icons.cloud_download_rounded,
                        ),
                        _MetricStatCard(
                          title: '3. Parsed (XML)',
                          count: metrics!.parsed,
                          color: Colors.indigo,
                          icon: Icons.code_rounded,
                        ),
                        _MetricStatCard(
                          title: '4. Normalized',
                          count: metrics!.normalized,
                          color: Colors.green,
                          icon: Icons.check_circle_rounded,
                        ),
                        _MetricStatCard(
                          title: 'Lỗi (Failed)',
                          count: metrics!.failed,
                          color: Colors.red,
                          icon: Icons.error_outline_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Article Tracking List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh sách các bài báo theo dõi (${articles.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isLoadingDetails)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  if (articles.isEmpty && !isLoadingDetails) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          'Chưa có bài báo nào được thu thập cho Job này.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: articles.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: AppColors.border),
                        itemBuilder: (context, index) {
                          final article = articles[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.title.isNotEmpty
                                            ? article.title
                                            : 'Không có tiêu đề',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'DOI: ${article.doi}  •  Năm: ${article.year ?? "N/A"}  •  Lần thử: ${article.retryCount}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                      if (article.errorMessage != null &&
                                          article.errorMessage!.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          'Lỗi: ${article.errorMessage}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.red.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _buildArticleStatusBadge(article.status),
                              ],
                            ),
                          );
                        },
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
  }

  Widget _buildStatusBadge(String status) {
    Color bg = Colors.blue.shade50;
    Color fg = Colors.blue.shade800;
    String label = status;

    if (status == 'COMPLETED') {
      bg = Colors.green.shade50;
      fg = Colors.green.shade800;
      label = 'Hoàn thành';
    } else if (status == 'FAILED') {
      bg = Colors.red.shade50;
      fg = Colors.red.shade800;
      label = 'Thất bại';
    } else if (status == 'PENDING') {
      bg = Colors.amber.shade50;
      fg = Colors.amber.shade900;
      label = 'Đang chờ (Pending)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildArticleStatusBadge(String status) {
    Color bg = Colors.grey.shade100;
    Color fg = Colors.grey.shade800;

    switch (status) {
      case 'HARVESTED':
        bg = Colors.blue.shade50;
        fg = Colors.blue.shade800;
        break;
      case 'FETCHED':
        bg = Colors.purple.shade50;
        fg = Colors.purple.shade800;
        break;
      case 'PARSED':
        bg = Colors.indigo.shade50;
        fg = Colors.indigo.shade800;
        break;
      case 'NORMALIZED':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case 'FAILED':
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

class _MetricStatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _MetricStatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineChip extends StatelessWidget {
  final String label;
  final String desc;

  const _PipelineChip({required this.label, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
