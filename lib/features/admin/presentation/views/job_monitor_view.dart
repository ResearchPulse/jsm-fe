import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/datasources/admin_api_client.dart';

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
  final AdminApiClient _apiClient = AdminApiClient();
  String _selectedFilter = 'Tất cả';
  List<Map<String, dynamic>> _jobs = [];
  bool _isLoading = true;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadJobs();
    // Auto-refresh every 8 seconds for live progress tracking
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) _loadJobs(silent: true);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadJobs({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final list = await _apiClient.getAnalysisJobs();
      if (!mounted) return;
      setState(() {
        _jobs = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (!silent) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _retryJob(String jobId) async {
    try {
      final retried = await _apiClient.retryFailedArticles(jobId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi lại $retried bài báo vào hàng đợi xử lý.'),
            backgroundColor: AppColors.green700,
          ),
        );
        _loadJobs();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  String _mapStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'RUNNING':
        return 'Đang xử lý';
      case 'COMPLETED':
        return 'Hoàn thành';
      case 'PENDING':
        return 'Hàng đợi';
      case 'FAILED':
        return 'Thất bại';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _mapStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'RUNNING':
        return AppColors.primary;
      case 'COMPLETED':
        return AppColors.green700;
      case 'PENDING':
        return const Color(0xFFD97706);
      case 'FAILED':
        return AppColors.error;
      case 'CANCELLED':
        return AppColors.textMuted;
      default:
        return AppColors.textSecondary;
    }
  }

  Future<void> _confirmCancelJob(String jobId, String journalTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xác nhận hủy tác vụ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Manrope',
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn dừng tác vụ khai phá của tạp chí "$journalTitle" không? Quá trình tải bài báo sẽ dừng lại.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Manrope'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Bỏ qua', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Manrope')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hủy tác vụ ngay', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _apiClient.cancelJob(jobId);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy tác vụ thành công.'),
            backgroundColor: AppColors.textPrimary,
          ),
        );
        _loadJobs();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể hủy tác vụ. Vui lòng thử lại.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteJob(String jobId, String journalTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Xác nhận xóa / hủy tác vụ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Manrope',
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn hủy và xóa tác vụ của tạp chí "$journalTitle" khỏi danh sách không? Toàn bộ dữ liệu thu thập của tác vụ này sẽ được dọn dẹp.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Manrope'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Bỏ qua', style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Manrope')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Xóa tác vụ', style: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _apiClient.deleteJob(jobId);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa tác vụ thành công khỏi hệ thống.'),
            backgroundColor: AppColors.textPrimary,
          ),
        );
        _loadJobs();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể xóa tác vụ. Vui lòng thử lại.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  int _currentStageNumber(String step, String status) {
    if (status.toUpperCase() == 'COMPLETED') return 6;
    final s = step.toUpperCase();
    if (s.contains('QUEUED') || s.contains('PENDING') || s.contains('HARVEST')) return 1;
    if (s.contains('FETCH')) return 2;
    if (s.contains('GROBID') || s.contains('PARS')) return 3;
    if (s.contains('NORM')) return 4;
    if (s.contains('NLP') || s.contains('MOVE') || s.contains('STANCE')) return 5;
    return 6;
  }

  String _stageDescription(int stageNum, String step, String status) {
    if (status.toUpperCase() == 'COMPLETED') {
      return 'Giai đoạn 6/6: Đóng gói Snapshot & Profile hoàn tất';
    }
    if (status.toUpperCase() == 'CANCELLED') {
      return 'Tác vụ đã dừng lại (Đã hủy bởi quản trị viên)';
    }
    switch (stageNum) {
      case 1:
        return 'Giai đoạn 1/6: Thu thập metadata bài báo (OpenAlex)';
      case 2:
        return 'Giai đoạn 2/6: Tải toàn văn PDF từ nguồn Open Access';
      case 3:
        return 'Giai đoạn 3/6: Grobid engine parsing TEI XML';
      case 4:
        return 'Giai đoạn 4/6: Chuẩn hóa Schema & Checksum SHA-256';
      case 5:
        return 'Giai đoạn 5/6: Trích xuất Stance & Rhetorical Moves NLP';
      case 6:
      default:
        return 'Giai đoạn 6/6: Đóng gói Corpus Snapshot & Hồ sơ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredJobs = _jobs.where((job) {
      if (_selectedFilter == 'Tất cả') return true;
      final st = _mapStatusText(job['status'] ?? '');
      return st == _selectedFilter;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Giám Sát Tác Vụ Khai Phá',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Manrope',
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Giám sát trạng thái các tác vụ khai phá dữ liệu, tra cứu nhật ký và xử lý lại bài lỗi.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _loadJobs(),
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Cập nhật trạng thái tác vụ',
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Filters Toolbar
          Row(
            children: [
              _buildFilterTab('Tất cả'),
              const SizedBox(width: 8),
              _buildFilterTab('Đang xử lý'),
              const SizedBox(width: 8),
              _buildFilterTab('Hàng đợi'),
              const SizedBox(width: 8),
              _buildFilterTab('Hoàn thành'),
              const SizedBox(width: 8),
              _buildFilterTab('Thất bại'),
              const SizedBox(width: 8),
              _buildFilterTab('Đã hủy'),
            ],
          ),
          const SizedBox(height: 20),

          // Job Cards List
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(64),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 36),
                    const SizedBox(height: 8),
                    Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Manrope')),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _loadJobs(),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredJobs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.monitor_heart_outlined, size: 48, color: AppColors.slate300),
                    const SizedBox(height: 12),
                    const Text(
                      'Không có tác vụ nào trong trạng thái đã chọn.',
                      style: TextStyle(color: AppColors.textMuted, fontFamily: 'Manrope', fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < filteredJobs.length; i++) ...[
                  _buildJobCard(filteredJobs[i]),
                  if (i < filteredJobs.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontFamily: 'Manrope',
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final journal = job['journal'] as Map<String, dynamic>?;
    final journalTitle = journal?['title'] ?? 'Tạp chí khai phá';
    final issn = journal?['issn_l'] ?? 'N/A';
    final status = (job['status'] ?? 'PENDING').toString();
    final step = (job['current_step'] ?? 'QUEUED').toString();
    final stageNum = _currentStageNumber(step, status);
    final stageText = _stageDescription(stageNum, step, status);

    double progress = ((job['progress'] as num?)?.toDouble() ?? 0.0);
    if (progress > 1.0) progress = progress / 100.0;
    progress = progress.clamp(0.0, 1.0);

    final statusText = _mapStatusText(status);
    final statusColor = _mapStatusColor(status);
    final jobId = job['id'].toString();

    final metrics = job['metrics'] as Map<String, dynamic>?;
    final totalArticles = (metrics?['total_articles'] as num?)?.toInt() ?? 0;
    final fetched = (metrics?['fetched'] as num?)?.toInt() ?? 0;
    final parsed = (metrics?['parsed'] as num?)?.toInt() ?? 0;
    final normalized = (metrics?['normalized'] as num?)?.toInt() ?? 0;
    final failed = (metrics?['failed'] as num?)?.toInt() ?? 0;
    final isDone = status.toUpperCase() == 'COMPLETED';

    final successCount = isDone
        ? totalArticles
        : (normalized > 0 ? normalized : (parsed > 0 ? parsed : fetched));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        journalTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ISSN: $issn',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Manrope'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mã Job: $jobId',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Manrope'),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                  if (failed > 0 || status == 'FAILED') ...[
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _retryJob(jobId),
                      icon: const Icon(Icons.refresh_rounded, size: 14),
                      label: Text(failed > 0 ? 'Thử lại $failed bài lỗi' : 'Thử lại'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        elevation: 0,
                      ),
                    ),
                  ],
                  if (status == 'RUNNING' || status == 'PENDING') ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _confirmCancelJob(jobId, journalTitle),
                      icon: const Icon(Icons.stop_circle_outlined, size: 14, color: AppColors.error),
                      label: const Text(
                        'Hủy job',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.error.withAlpha(120)),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _confirmDeleteJob(jobId, journalTitle),
                    icon: const Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.error),
                    label: const Text(
                      'Hủy / Xóa',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Progress Bar with Article Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stageText,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Manrope'),
              ),
              Row(
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Manrope'),
                  ),
                  if (totalArticles > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      '•  $successCount/$totalArticles bài báo',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceSoft,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 14),

          // Real-time Article State Tracking Strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withAlpha(120)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Wrap(
                  spacing: 14,
                  runSpacing: 6,
                  children: [
                    _buildMetricBadge(
                      icon: Icons.article_outlined,
                      label: 'Tổng mục tiêu',
                      value: '$totalArticles',
                    ),
                    _buildMetricBadge(
                      icon: Icons.download_done_rounded,
                      label: 'Đã tải PDF',
                      value: '$fetched',
                    ),
                    _buildMetricBadge(
                      icon: Icons.integration_instructions_outlined,
                      label: 'Parse TEI XML',
                      value: '$parsed',
                    ),
                    _buildMetricBadge(
                      icon: Icons.verified_outlined,
                      label: 'Chuẩn hóa DB',
                      value: '$normalized',
                    ),
                    if (failed > 0)
                      _buildMetricBadge(
                        icon: Icons.warning_amber_rounded,
                        label: 'Bài lỗi',
                        value: '$failed',
                        color: AppColors.error,
                      ),
                  ],
                ),
                OutlinedButton.icon(
                  onPressed: () => _showJobArticlesDialog(context, jobId, journalTitle, metrics, status: status),
                  icon: const Icon(Icons.format_list_bulleted_rounded, size: 14, color: AppColors.textSecondary),
                  label: const Text(
                    'Chi tiết từng bài báo',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Manrope'),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBadge({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    final finalColor = color ?? AppColors.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textPrimary),
        const SizedBox(width: 5),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontFamily: 'Manrope',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: finalColor,
            fontFamily: 'Manrope',
          ),
        ),
      ],
    );
  }

  void _showJobArticlesDialog(
    BuildContext context,
    String jobId,
    String journalTitle,
    Map<String, dynamic>? metrics, {
    String status = '',
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        String filter = 'ALL';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chi tiết bài báo: $journalTitle',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontFamily: 'Manrope',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mã Job: $jobId • Tổng ${(metrics?['total_articles'] as num?)?.toInt() ?? 0} bài',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              content: SizedBox(
                width: 700,
                height: 480,
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildDialogFilterChip('Tất cả', 'ALL', filter, (val) => setDialogState(() => filter = val)),
                        const SizedBox(width: 8),
                        _buildDialogFilterChip('Đã chuẩn hóa TEI', 'NORMALIZED', filter, (val) => setDialogState(() => filter = val)),
                        const SizedBox(width: 8),
                        _buildDialogFilterChip('Đã tải PDF', 'FETCHED', filter, (val) => setDialogState(() => filter = val)),
                        const SizedBox(width: 8),
                        _buildDialogFilterChip('Lỗi', 'FAILED', filter, (val) => setDialogState(() => filter = val), isError: true),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _apiClient.getJobArticles(jobId, perPage: 100),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                'Lỗi tải danh sách bài báo: ${snapshot.error}',
                                style: const TextStyle(color: AppColors.error, fontFamily: 'Manrope'),
                              ),
                            );
                          }
                          final allArticles = snapshot.data ?? [];
                          final filtered = allArticles.where((a) {
                            if (filter == 'ALL') return true;
                            return (a['status'] ?? '').toString().toUpperCase() == filter;
                          }).toList();

                          if (filtered.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.inbox_outlined, size: 40, color: AppColors.slate300),
                                  const SizedBox(height: 8),
                                  Text(
                                    allArticles.isEmpty
                                        ? 'Chưa có bài báo nào được ghi nhận trong job này.'
                                        : 'Không có bài báo nào với trạng thái này.',
                                    style: const TextStyle(color: AppColors.textMuted, fontFamily: 'Manrope', fontSize: 13),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (ctx, i) => const Divider(height: 1, color: AppColors.border),
                            itemBuilder: (context, index) {
                              final art = filtered[index];
                              final artStatus = (art['status'] ?? '').toString().toUpperCase();
                              final artTitle = (art['title'] ?? 'Bài báo không tiêu đề').toString();
                              final doi = (art['doi'] ?? 'N/A').toString();
                              final year = art['year']?.toString() ?? 'N/A';
                              final errorMsg = art['error_message']?.toString();

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildArticleStatusIcon(artStatus),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            artTitle,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                              fontFamily: 'Manrope',
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                'DOI: $doi',
                                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Manrope'),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Năm: $year',
                                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Manrope'),
                                              ),
                                            ],
                                          ),
                                          if (errorMsg != null && errorMsg.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'Lỗi: $errorMsg',
                                              style: const TextStyle(fontSize: 11, color: AppColors.error, fontFamily: 'Manrope'),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildArticleStatusBadge(artStatus),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (((metrics?['failed'] as num?)?.toInt() ?? 0) > 0)
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _retryJob(jobId);
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    label: Text('Thử lại ${(metrics?['failed'] as num?)?.toInt()} bài lỗi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _confirmDeleteJob(jobId, journalTitle);
                  },
                  icon: const Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.error),
                  label: const Text(
                    'Xóa tác vụ',
                    style: TextStyle(fontFamily: 'Manrope', color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withAlpha(120)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Đóng', style: TextStyle(fontFamily: 'Manrope')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDialogFilterChip(String label, String value, String current, Function(String) onSelect, {bool isError = false}) {
    final isSelected = current == value;
    return InkWell(
      onTap: () => onSelect(value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isError ? AppColors.error : AppColors.primary)
              : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? (isError ? AppColors.error : AppColors.primary)
                : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : (isError ? AppColors.error : AppColors.textSecondary),
            fontFamily: 'Manrope',
          ),
        ),
      ),
    );
  }

  Widget _buildArticleStatusIcon(String status) {
    switch (status) {
      case 'NORMALIZED':
        return const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.green700);
      case 'PARSED':
        return const Icon(Icons.integration_instructions_outlined, size: 18, color: AppColors.primary);
      case 'FETCHED':
        return const Icon(Icons.download_done_rounded, size: 18, color: Color(0xFF6366F1));
      case 'FAILED':
        return const Icon(Icons.error_outline_rounded, size: 18, color: AppColors.error);
      case 'HARVESTED':
      default:
        return const Icon(Icons.schedule_rounded, size: 18, color: AppColors.textMuted);
    }
  }

  Widget _buildArticleStatusBadge(String status) {
    Color col;
    String txt;
    switch (status) {
      case 'NORMALIZED':
        col = AppColors.green700;
        txt = 'Chuẩn hóa TEI';
        break;
      case 'PARSED':
        col = AppColors.primary;
        txt = 'Parse TEI';
        break;
      case 'FETCHED':
        col = const Color(0xFF6366F1);
        txt = 'Đã tải PDF';
        break;
      case 'FAILED':
        col = AppColors.error;
        txt = 'Lỗi';
        break;
      case 'HARVESTED':
      default:
        col = AppColors.textMuted;
        txt = 'Đang chờ';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: col.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        txt,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: col, fontFamily: 'Manrope'),
      ),
    );
  }
}
