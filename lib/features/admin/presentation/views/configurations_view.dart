import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/datasources/admin_api_client.dart';

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
  final AdminApiClient _apiClient = AdminApiClient();
  List<Map<String, dynamic>> _configs = [];
  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _apiClient.getConfigurations(),
        _apiClient.getJournals(),
      ]);
      if (!mounted) return;
      setState(() {
        _configs = results[0];
        _journals = results[1];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showConfigDialog(BuildContext context) {
    if (_journals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng ký ít nhất một tạp chí trước khi thiết lập cấu hình.')),
      );
      return;
    }

    String selectedJournalId = _journals.first['id'].toString();
    int yearStart = 2021;
    int yearEnd = 2024;
    double targetPapers = 200;
    final domainController = TextEditingController(
      text: _journals.first['publisher'] ?? 'Khoa học máy tính & Công nghệ',
    );
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Thiết lập cấu hình khai phá mới',
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
                      'Xác định khoảng năm xuất bản và số lượng bài báo mục tiêu để Grobid bóc tách cấu trúc TEI XML.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontFamily: 'Manrope'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Tạp chí áp dụng *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedJournalId,
                      isExpanded: true,
                      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                      items: _journals.map((j) {
                        return DropdownMenuItem<String>(
                          value: j['id'].toString(),
                          child: Text(
                            '${j['title']} (${j['issn_l'] ?? 'No ISSN'})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13, fontFamily: 'Manrope'),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedJournalId = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Lĩnh vực nghiên cứu (Domain) *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                    const SizedBox(height: 6),
                    TextField(
                      controller: domainController,
                      decoration: const InputDecoration(
                        hintText: 'Ví dụ: Software Engineering / Computer Science',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Từ năm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                initialValue: yearStart,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                                items: [2018, 2019, 2020, 2021, 2022, 2023].map((y) {
                                  return DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(fontFamily: 'Manrope')));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => yearStart = val);
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
                              const Text('Đến năm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                initialValue: yearEnd,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                                items: [2022, 2023, 2024, 2025, 2026].map((y) {
                                  return DropdownMenuItem(value: y, child: Text('$y', style: const TextStyle(fontFamily: 'Manrope')));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => yearEnd = val);
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
                        const Text('Số bài báo mục tiêu (Target)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                        Text(
                          '${targetPapers.toInt()} bài',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Manrope'),
                        ),
                      ],
                    ),
                    Slider(
                      value: targetPapers,
                      min: 20,
                      max: 500,
                      divisions: 48,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setModalState(() => targetPapers = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final domain = domainController.text.trim();
                          if (domain.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập tên lĩnh vực nghiên cứu.')),
                            );
                            return;
                          }

                          setModalState(() => isSaving = true);
                          try {
                            await _apiClient.createConfiguration(
                              journalId: selectedJournalId,
                              domain: domain,
                              yearFrom: yearStart,
                              yearTo: yearEnd,
                              targetArticles: targetPapers.toInt(),
                              referenceCorpusName: 'Academic Core Corpus',
                            );
                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã tạo cấu hình khai phá thành công.'),
                                  backgroundColor: AppColors.green700,
                                ),
                              );
                            }
                            _loadData();
                          } catch (err) {
                            setModalState(() => isSaving = false);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi: $err'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: isSaving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Lưu cấu hình'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _triggerAnalysis(String configId, String journalName) async {
    try {
      await _apiClient.triggerAnalysis(configId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã kích hoạt chu trình phân tích cho: $journalName'),
            backgroundColor: AppColors.green700,
          ),
        );
        widget.onNavigateToTab(3); // Navigate to Job Monitor
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kích hoạt: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteConfig(String configId) async {
    try {
      await _apiClient.deleteConfiguration(configId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa cấu hình khai phá.')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Cấu Hình Tham Số Khai Phá',
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
                    'Thiết lập phạm vi năm khảo sát, số lượng bài báo mục tiêu và hồ sơ TEI XML phục vụ bóc tách cấu trúc với Grobid.',
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
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Tải lại cấu hình',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showConfigDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Thiết lập cấu hình mới'),
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

          // State Handling
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
                      onPressed: _loadData,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (_configs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.tune_rounded, size: 48, color: AppColors.slate300),
                    const SizedBox(height: 12),
                    const Text(
                      'Chưa có cấu hình khai phá nào được tạo.',
                      style: TextStyle(color: AppColors.textMuted, fontFamily: 'Manrope', fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showConfigDialog(context),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Tạo cấu hình đầu tiên'),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < _configs.length; i++) ...[
                  _buildConfigCard(_configs[i]),
                  if (i < _configs.length - 1) const SizedBox(height: 16),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildConfigCard(Map<String, dynamic> config) {
    final journal = config['journal'] as Map<String, dynamic>?;
    final journalTitle = journal?['title'] ?? 'Tạp chí áp dụng';
    final domain = config['domain'] ?? 'Khoa học tổng hợp';
    final yearFrom = config['year_from'] ?? 2021;
    final yearTo = config['year_to'] ?? 2024;
    final targetArticles = config['target_articles'] ?? 200;
    final isActive = config['is_active'] ?? true;
    final configId = config['id'].toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primary.withAlpha(80) : AppColors.border,
          width: isActive ? 1.5 : 1,
        ),
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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.blue50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            domain,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          if (isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.blue50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Active Profile',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Áp dụng cho: $journalTitle',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _deleteConfig(configId),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                    label: const Text('Xóa', style: TextStyle(color: AppColors.error, fontSize: 12, fontFamily: 'Manrope')),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _triggerAnalysis(configId, journalTitle),
                    icon: const Icon(Icons.bolt_rounded, size: 16),
                    label: const Text('Khai phá với cấu hình này'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: AppColors.borderSoft),
          const SizedBox(height: 16),

          // Specs grid
          Row(
            children: [
              _buildSpecItem('KHOẢNG NĂM KHẢO SÁT', '$yearFrom - $yearTo', Icons.calendar_today_rounded),
              _buildSpecItem('MỤC TIÊU BÀI BÁO', '$targetArticles bài báo', Icons.description_outlined),
              _buildSpecItem('CHẾ ĐỘ GROBID PARSER', 'Toàn văn TEI XML (Sections, Moves)', Icons.code_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSubtle),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSubtle,
                  fontFamily: 'Manrope',
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
