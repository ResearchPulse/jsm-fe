import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/datasources/admin_api_client.dart';

class JournalsView extends StatefulWidget {
  final Function(int) onNavigateToTab;
  final VoidCallback? onTriggerNewAnalysis;

  const JournalsView({
    super.key,
    required this.onNavigateToTab,
    this.onTriggerNewAnalysis,
  });

  @override
  State<JournalsView> createState() => _JournalsViewState();
}

class _JournalsViewState extends State<JournalsView> {
  final AdminApiClient _apiClient = AdminApiClient();
  String _searchQuery = '';
  String _selectedDomain = 'Tất cả';

  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  Future<void> _loadJournals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _apiClient.getJournals();
      if (!mounted) return;
      setState(() {
        _journals = list;
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

  void _showAddJournalDialog(BuildContext context) {
    final titleController = TextEditingController();
    final issnController = TextEditingController();
    final publisherController = TextEditingController();
    final openalexController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Đăng ký Tạp chí Khoa học mới',
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
                      'Tên Tạp chí đầy đủ (Title) *',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Manrope'),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: IEEE Transactions on Software Engineering',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSubtle),
                        fillColor: AppColors.surfaceSoft,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Mã chuẩn quốc tế ISSN / ISSN-L *',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Manrope'),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: issnController,
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: 0098-5589',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSubtle),
                        fillColor: AppColors.surfaceSoft,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Nhà xuất bản (Publisher)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Manrope'),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: publisherController,
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: IEEE Computer Society / Springer / ACM',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSubtle),
                        fillColor: AppColors.surfaceSoft,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'OpenAlex Source URI (Tùy chọn)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Manrope'),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: openalexController,
                      decoration: InputDecoration(
                        hintText: 'Ví dụ: https://openalex.org/S8351582',
                        hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSubtle),
                        fillColor: AppColors.surfaceSoft,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final issn = issnController.text.trim();
                          if (title.isEmpty || issn.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập tên tạp chí và mã ISSN')),
                            );
                            return;
                          }

                          setModalState(() => isSubmitting = true);
                          try {
                            final openalexId = openalexController.text.trim().isNotEmpty
                                ? openalexController.text.trim()
                                : 'https://openalex.org/S_${issn.replaceAll('-', '')}';

                            await _apiClient.importJournal(
                              openalexId: openalexId,
                              title: title,
                              issnL: issn,
                              issns: [issn],
                              publisher: publisherController.text.trim().isNotEmpty
                                  ? publisherController.text.trim()
                                  : 'Academic Publisher',
                            );

                            if (ctx.mounted) Navigator.of(ctx).pop();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã đăng ký tạp chí thành công vào cơ sở dữ liệu.'),
                                  backgroundColor: AppColors.green700,
                                ),
                              );
                            }
                            _loadJournals();
                          } catch (err) {
                            setModalState(() => isSubmitting = false);
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
                  child: isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Lưu tạp chí'),
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
    final filteredJournals = _journals.where((j) {
      final title = (j['title'] ?? '').toString().toLowerCase();
      final issn = (j['issn_l'] ?? '').toString().toLowerCase();
      final publisher = (j['publisher'] ?? '').toString().toLowerCase();
      final q = _searchQuery.toLowerCase();

      final matchesSearch = title.contains(q) || issn.contains(q) || publisher.contains(q);
      final matchesDomain = _selectedDomain == 'Tất cả' || (j['domain'] ?? '') == _selectedDomain;
      return matchesSearch && matchesDomain;
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
                    'Danh Mục Tạp Chí Khoa Học',
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
                    'Đăng ký và quản lý tạp chí nghiên cứu với mã ISSN chuẩn quốc tế, theo dõi số bài báo và kích hoạt khai phá.',
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
                    onPressed: _loadJournals,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Tải lại danh sách',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddJournalDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Đăng ký tạp chí mới'),
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

          // Search & Filter Toolbar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(fontSize: 14, fontFamily: 'Manrope'),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên tạp chí, mã ISSN, nhà xuất bản...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSubtle, fontFamily: 'Manrope'),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSubtle),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      fillColor: AppColors.surfaceSoft,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildFilterChip('Tất cả'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Journals Data List
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Table header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          'TÊN TẠP CHÍ & NHÀ XUẤT BẢN',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSubtle, fontFamily: 'Manrope'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'MÃ ISSN',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSubtle, fontFamily: 'Manrope'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'TỔNG BÀI BÁO',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSubtle, fontFamily: 'Manrope'),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'LƯỢT TRÍCH DẪN',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSubtle, fontFamily: 'Manrope'),
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: Text(
                          'THAO TÁC',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSubtle, fontFamily: 'Manrope'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Table state handling
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(48),
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
                            onPressed: _loadJournals,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (filteredJournals.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'Không tìm thấy tạp chí nào phù hợp trong cơ sở dữ liệu.',
                        style: TextStyle(color: AppColors.textMuted, fontFamily: 'Manrope'),
                      ),
                    ),
                  )
                else
                  for (int i = 0; i < filteredJournals.length; i++) ...[
                    _buildJournalRow(filteredJournals[i]),
                    if (i < filteredJournals.length - 1)
                      const Divider(height: 1, color: AppColors.borderSoft),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedDomain == label;
    return InkWell(
      onTap: () => setState(() => _selectedDomain = label),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontFamily: 'Manrope',
          ),
        ),
      ),
    );
  }

  Widget _buildJournalRow(Map<String, dynamic> journal) {
    final title = journal['title'] ?? 'Chưa rõ';
    final publisher = journal['publisher'] ?? 'Chưa rõ nhà xuất bản';
    final issn = journal['issn_l'] ??
        ((journal['issns'] is List && (journal['issns'] as List).isNotEmpty)
            ? journal['issns'][0].toString()
            : 'N/A');
    final worksCount = journal['works_count'] ?? 0;
    final citedCount = journal['cited_by_count'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  publisher,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              issn,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Manrope',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$worksCount bài',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Manrope',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$citedCount lượt',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                fontFamily: 'Manrope',
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => widget.onNavigateToTab(2),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Cấu hình', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => widget.onNavigateToTab(3),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Khai phá', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Manrope')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
