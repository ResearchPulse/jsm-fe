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
      default:
        return AppColors.textSecondary;
    }
  }

  int _currentStageNumber(String step, String status) {
    if (status.toUpperCase() == 'COMPLETED') return 6;
    final s = step.toUpperCase();
    if (s.contains('QUEUED') || s.contains('PENDING')) return 1;
    if (s.contains('HARVEST')) return 2;
    if (s.contains('GROBID') || s.contains('PARS')) return 3;
    if (s.contains('NORM')) return 4;
    if (s.contains('NLP') || s.contains('MOVE') || s.contains('STANCE')) return 5;
    return 6;
  }

  String _stageDescription(int stageNum, String step, String status) {
    if (status.toUpperCase() == 'COMPLETED') {
      return 'Giai đoạn 6/6: Đóng gói Snapshot & Profile hoàn tất';
    }
    switch (stageNum) {
      case 1:
        return 'Giai đoạn 1/6: Hàng đợi thu thập metadata OpenAlex';
      case 2:
        return 'Giai đoạn 2/6: Tải toàn văn PDF từ Open Access';
      case 3:
        return 'Giai đoạn 3/6: Grobid parsing TEI XML';
      case 4:
        return 'Giai đoạn 4/6: Chuẩn hóa Schema và Checksum SHA-256';
      case 5:
        return 'Giai đoạn 5/6: Trích xuất Stance & Moves NLP';
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
                    'Theo dõi tiến độ toàn trình theo thời gian thực: Tải PDF ➔ Grobid Parse TEI ➔ NLP Trích xuất ➔ Freeze Snapshot.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _loadJobs(),
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Cập nhật trạng thái tác vụ',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: widget.onTriggerNewAnalysis,
                    icon: const Icon(Icons.bolt_rounded, size: 18),
                    label: const Text('Bắt đầu phân tích mới'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Interactive Stage Pipeline Stepper
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TIẾN TRÌNH KHAI PHÁ DỮ LIỆU ĐANG VẬN HÀNH',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSubtle,
                    fontFamily: 'Manrope',
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildStepperStage(1, 'OpenAlex Crawl', isDone: true, isActive: false),
                    _buildStepperLine(isDone: true),
                    _buildStepperStage(2, 'PDF Harvester', isDone: true, isActive: false),
                    _buildStepperLine(isDone: true),
                    _buildStepperStage(3, 'Grobid TEI XML', isDone: false, isActive: true),
                    _buildStepperLine(isDone: false),
                    _buildStepperStage(4, 'Normalizer', isDone: false, isActive: false),
                    _buildStepperLine(isDone: false),
                    _buildStepperStage(5, 'NLP Moves & Stance', isDone: false, isActive: false),
                    _buildStepperLine(isDone: false),
                    _buildStepperStage(6, 'Freeze Snapshot', isDone: false, isActive: false),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

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

  Widget _buildStepperStage(int number, String label, {required bool isDone, required bool isActive}) {
    Color bg = AppColors.surfaceSoft;
    Color border = AppColors.border;
    Color textCol = AppColors.textSubtle;

    if (isDone) {
      bg = AppColors.green50;
      border = AppColors.green700;
      textCol = AppColors.green700;
    } else if (isActive) {
      bg = AppColors.blue50;
      border = AppColors.primary;
      textCol = AppColors.primary;
    }

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
              border: Border.all(color: border, width: 2),
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check_rounded, size: 16, color: AppColors.green700)
                  : Text('$number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textCol, fontFamily: 'Manrope')),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperLine({required bool isDone}) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      color: isDone ? AppColors.green700 : AppColors.border,
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
                  if (status == 'FAILED') ...[
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _retryJob(jobId),
                      icon: const Icon(Icons.refresh_rounded, size: 14, color: AppColors.primary),
                      label: const Text('Thử lại', style: TextStyle(fontSize: 12, color: AppColors.primary, fontFamily: 'Manrope')),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Progress Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stageText,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Manrope'),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Manrope'),
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
        ],
      ),
    );
  }
}
