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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDomain = 'Tất cả';

  List<Map<String, dynamic>> _journals = [];
  bool _isLoading = true;
  String? _error;

  // OpenAlex live fallback search state
  List<Map<String, dynamic>> _openAlexResults = [];
  bool _isSearchingOpenAlex = false;
  String? _openAlexSearchError;
  String? _lastSearchedOpenAlexQuery;
  final Set<String> _importingIds = {};

  @override
  void initState() {
    super.initState();
    _loadJournals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchOpenAlex([String? query]) async {
    final q = (query ?? _searchQuery).trim();
    if (q.isEmpty) return;

    setState(() {
      _isSearchingOpenAlex = true;
      _openAlexSearchError = null;
      _lastSearchedOpenAlexQuery = q;
      _openAlexResults = [];
    });

    try {
      final results = await _apiClient.searchOpenAlexJournals(q);
      if (!mounted) return;
      setState(() {
        _openAlexResults = results;
        _isSearchingOpenAlex = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _openAlexSearchError = e.toString();
        _isSearchingOpenAlex = false;
      });
    }
  }

  Future<void> _importOpenAlexJournal(Map<String, dynamic> journal) async {
    final openalexId = journal['openalex_id']?.toString() ?? '';
    final title = journal['title']?.toString() ?? '';
    final issnL = journal['issn_l']?.toString();
    final issns = (journal['issns'] is List)
        ? (journal['issns'] as List).map((e) => e.toString()).toList()
        : (issnL != null ? [issnL] : <String>[]);
    final publisher = journal['publisher']?.toString();
    final homepage = journal['homepage_url']?.toString();

    setState(() {
      _importingIds.add(openalexId);
    });

    try {
      await _apiClient.importJournal(
        openalexId: openalexId,
        title: title,
        issnL: issnL,
        issns: issns,
        publisher: publisher,
        homepageUrl: homepage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã nạp "$title" vào cơ sở dữ liệu thành công.'),
          backgroundColor: AppColors.green700,
        ),
      );

      setState(() {
        journal['is_imported'] = true;
        _importingIds.remove(openalexId);
      });

      await _loadJournals();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _importingIds.remove(openalexId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi nạp tạp chí: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
              title: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhập Tạp chí thủ công',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Manrope',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Dành cho tạp chí nội bộ, trong nước hoặc chưa có trên OpenAlex.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Manrope',
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
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
                  OutlinedButton.icon(
                    onPressed: () => _showAddJournalDialog(context),
                    icon: const Icon(Icons.post_add_rounded, size: 18),
                    label: const Text('Nhập thủ công', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    onSubmitted: (val) => _searchOpenAlex(val),
                    style: const TextStyle(fontSize: 14, fontFamily: 'Manrope'),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên tạp chí, mã ISSN, nhà xuất bản...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSubtle, fontFamily: 'Manrope'),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSubtle),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 16, color: AppColors.textSubtle),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _openAlexResults = [];
                                  _lastSearchedOpenAlexQuery = null;
                                });
                              },
                            )
                          : null,
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
                const SizedBox(width: 12),
                _buildFilterChip('Tất cả'),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _searchQuery.trim().isEmpty || _isSearchingOpenAlex
                      ? null
                      : () => _searchOpenAlex(_searchQuery),
                  icon: _isSearchingOpenAlex
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.travel_explore_rounded, size: 16),
                  label: const Text(
                    'Tra cứu OpenAlex',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Manrope'),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
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
                  _buildEmptyOrOpenAlexFallback()
                else ...[
                  for (int i = 0; i < filteredJournals.length; i++) ...[
                    _buildJournalRow(filteredJournals[i]),
                    if (i < filteredJournals.length - 1)
                      const Divider(height: 1, color: AppColors.borderSoft),
                  ],
                  if (_openAlexResults.isNotEmpty) ...[
                    const Divider(height: 1, color: AppColors.border),
                    _buildOpenAlexHeaderBanner(),
                    for (int i = 0; i < _openAlexResults.length; i++) ...[
                      _buildOpenAlexJournalRow(_openAlexResults[i]),
                      if (i < _openAlexResults.length - 1)
                        const Divider(height: 1, color: AppColors.borderSoft),
                    ],
                  ],
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

  Widget _buildEmptyOrOpenAlexFallback() {
    if (_isSearchingOpenAlex) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Đang tra cứu "$_searchQuery" trên OpenAlex toàn cầu...',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hệ thống đang kết nối trực tiếp đến chỉ mục học thuật mở OpenAlex',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Manrope'),
              ),
            ],
          ),
        ),
      );
    }

    if (_openAlexResults.isNotEmpty) {
      return Column(
        children: [
          _buildOpenAlexHeaderBanner(),
          for (int i = 0; i < _openAlexResults.length; i++) ...[
            _buildOpenAlexJournalRow(_openAlexResults[i]),
            if (i < _openAlexResults.length - 1)
              const Divider(height: 1, color: AppColors.borderSoft),
          ],
        ],
      );
    }

    if (_lastSearchedOpenAlexQuery != null &&
        _lastSearchedOpenAlexQuery == _searchQuery.trim() &&
        _openAlexResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.search_off_rounded, size: 40, color: AppColors.textSubtle),
              const SizedBox(height: 12),
              Text(
                'Không tìm thấy tạp chí nào có tên hoặc ISSN "$_searchQuery" trên OpenAlex.',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Vui lòng thử từ khóa khác (ví dụ: "IEEE", "Finance", "Nature") hoặc mã ISSN.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Manrope'),
              ),
            ],
          ),
        ),
      );
    }

    if (_searchQuery.trim().isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 580),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.travel_explore_rounded, color: AppColors.primary, size: 26),
                ),
                const SizedBox(height: 14),
                Text(
                  'Không tìm thấy "$_searchQuery" trong CSDL nội bộ',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tạp chí này chưa được lưu trữ trong hệ thống. Bạn có muốn tra cứu trực tiếp từ kho học thuật toàn cầu OpenAlex để nạp vào không?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFamily: 'Manrope',
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () => _searchOpenAlex(_searchQuery),
                  icon: const Icon(Icons.travel_explore_rounded, size: 16),
                  label: Text('Tra cứu "$_searchQuery" trên OpenAlex'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.menu_book_outlined, size: 40, color: AppColors.textSubtle),
            const SizedBox(height: 8),
            const Text(
              'Chưa có tạp chí nào trong cơ sở dữ liệu.',
              style: TextStyle(color: AppColors.textMuted, fontFamily: 'Manrope'),
            ),
            const SizedBox(height: 6),
            const Text(
              'Gõ tên tạp chí vào ô tìm kiếm ở trên để tra cứu từ OpenAlex, hoặc nhập thủ công.',
              style: TextStyle(fontSize: 12, color: AppColors.textSubtle, fontFamily: 'Manrope'),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () => _showAddJournalDialog(context),
              icon: const Icon(Icons.post_add_rounded, size: 16),
              label: const Text('Nhập thủ công', style: TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Manrope')),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpenAlexHeaderBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        border: const Border(
          bottom: BorderSide(color: AppColors.borderSoft),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.travel_explore_rounded, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Kết quả tra cứu từ OpenAlex (${_openAlexResults.length} tạp chí phù hợp):',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontFamily: 'Manrope',
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _openAlexResults = [];
                _lastSearchedOpenAlexQuery = null;
              });
            },
            icon: const Icon(Icons.close_rounded, size: 14),
            label: const Text('Ẩn kết quả OpenAlex', style: TextStyle(fontSize: 11)),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenAlexJournalRow(Map<String, dynamic> journal) {
    final title = journal['title'] ?? 'Chưa rõ';
    final publisher = journal['publisher'] ?? 'Chưa rõ nhà xuất bản';
    final issn = journal['issn_l'] ??
        ((journal['issns'] is List && (journal['issns'] as List).isNotEmpty)
            ? journal['issns'][0].toString()
            : 'N/A');
    final worksCount = journal['works_count'] ?? 0;
    final citedCount = journal['cited_by_count'] ?? 0;
    final openalexId = journal['openalex_id']?.toString() ?? '';
    final isImported = journal['is_imported'] == true;
    final isImporting = _importingIds.contains(openalexId);

    return Container(
      color: Colors.blue.withOpacity(0.02),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'OpenAlex',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                  ],
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
                if (isImported)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.green700.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.green700.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: AppColors.green700),
                        SizedBox(width: 4),
                        Text(
                          'Đã trong CSDL',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.green700,
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: isImporting ? null : () => _importOpenAlexJournal(journal),
                    icon: isImporting
                        ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add_rounded, size: 15),
                    label: Text(
                      isImporting ? 'Đang nạp...' : 'Thêm vào CSDL',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, fontFamily: 'Manrope'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
}
