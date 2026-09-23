import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/models/openalex_journal_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class JournalsView extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const JournalsView({
    super.key,
    required this.onNavigateToTab,
  });

  @override
  State<JournalsView> createState() => _JournalsViewState();
}

class _JournalsViewState extends State<JournalsView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AdminCubit>();
    if (cubit.state.openAlexJournals.isEmpty && !cubit.state.isSearching) {
      cubit.searchOpenAlex('IEEE', page: 1);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final text = _searchController.text.trim();
    context.read<AdminCubit>().searchOpenAlex(text, page: 1);
  }

  void _quickSearch(String keyword) {
    _searchController.text = keyword;
    context.read<AdminCubit>().searchOpenAlex(keyword, page: 1);
  }

  void _onPageChanged(int page) {
    context.read<AdminCubit>().changeOpenAlexPage(page);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Registry Card / Header
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
                                'OpenAlex Explorer',
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
                              tooltip: 'Tải lại danh sách',
                              icon: const Icon(Icons.refresh_rounded, size: 20),
                              onPressed: () => context
                                  .read<AdminCubit>()
                                  .searchOpenAlex(state.searchQuery),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Kho Bài Báo & Tạp Chí Khoa Học',
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
                          'Khám phá danh mục tạp chí khoa học từ OpenAlex và tự động kiểm tra trạng thái phân tích phong cách học thuật trong hệ thống.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                            fontFamily: 'Manrope',
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Search Input Bar
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onSubmitted: (_) => _onSearch(),
                                decoration: InputDecoration(
                                  hintText:
                                      'Tìm kiếm theo tên tạp chí, ISSN hoặc chủ đề (ví dụ: IEEE TSE, Nature, Software)...',
                                  prefixIcon: const Icon(Icons.search_rounded,
                                      size: 20, color: AppColors.textMuted),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded,
                                              size: 18),
                                          onPressed: () {
                                            _searchController.clear();
                                            _onSearch();
                                          },
                                        )
                                      : null,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  filled: true,
                                  fillColor: AppColors.surfaceSoft,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: AppColors.border),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        const BorderSide(color: AppColors.border),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: state.isSearching ? null : _onSearch,
                              icon: const Icon(Icons.search_rounded, size: 18),
                              label: const Text('Tìm kiếm'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        // Quick Suggestions
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Gợi ý tìm nhanh:',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            _buildQuickChip('IEEE Transactions'),
                            _buildQuickChip('Nature Machine Intelligence'),
                            _buildQuickChip('Software Engineering'),
                            _buildQuickChip('Journal of Medical Systems'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Results Section
                  if (state.isSearching) ...[
                    _buildSkeletonGrid(),
                  ] else if (state.searchError != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: Colors.red.shade700, size: 24),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              state.searchError!,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context
                                .read<AdminCubit>()
                                .searchOpenAlex(state.searchQuery, page: state.currentPage),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ] else if (state.openAlexJournals.isEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.find_in_page_outlined,
                              size: 48, color: AppColors.textMuted),
                          SizedBox(height: 12),
                          Text(
                            'Không tìm thấy tạp chí nào phù hợp.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Vui lòng nhập từ khóa khác hoặc kiểm tra lại mã ISSN.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tìm thấy ${state.totalCount > 0 ? state.totalCount : state.openAlexJournals.length} tạp chí phù hợp${state.totalPages > 1 ? " (Trang ${state.currentPage}/${state.totalPages})" : ""}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Đã auto-check trạng thái từ DB nội bộ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3-Column Responsive Grid of Journals
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final crossAxisCount = width >= 1050
                            ? 3
                            : (width >= 680 ? 2 : 1);
                        final itemHeight = crossAxisCount == 1 ? 210.0 : 230.0;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.openAlexJournals.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            mainAxisExtent: itemHeight,
                          ),
                          itemBuilder: (context, index) {
                            final journal = state.openAlexJournals[index];
                            return _JournalCardWidget(
                              key: ValueKey('${journal.openalexId}_${state.currentPage}'),
                              journal: journal,
                              onConfigure: () {
                                context
                                    .read<AdminCubit>()
                                    .selectJournalForConfig(journal);
                                widget.onNavigateToTab(2); // Cấu hình tạp chí
                              },
                              onViewJob: () => widget.onNavigateToTab(3), // Job Monitor
                            )
                            .animate(key: ValueKey('anim_${journal.openalexId}_${state.currentPage}'))
                            .fadeIn(
                              duration: 350.ms,
                              delay: (index * 40).ms,
                              curve: Curves.easeOutCubic,
                            )
                            .slideY(
                              begin: 0.08,
                              end: 0,
                              duration: 350.ms,
                              delay: (index * 40).ms,
                              curve: Curves.easeOutCubic,
                            );
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Pagination controls
                    _buildPaginationBar(context, state),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickChip(String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      backgroundColor: AppColors.surfaceSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      onPressed: () => _quickSearch(label),
    );
  }

  Widget _buildSkeletonGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 1050 ? 3 : (width >= 680 ? 2 : 1);
        final itemHeight = crossAxisCount == 1 ? 210.0 : 230.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 9,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: itemHeight,
          ),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceSoft,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 70,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: List.generate(
                      4,
                      (i) => Container(
                        width: 65 + (i * 15).toDouble(),
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Divider(height: 16, color: AppColors.border),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 90,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shimmer(
              duration: 1200.ms,
              color: AppColors.primary.withAlpha(20),
            );
          },
        );
      },
    );
  }

  Widget _buildPaginationBar(BuildContext context, AdminState state) {
    if (state.totalPages <= 1) return const SizedBox.shrink();

    final currentPage = state.currentPage;
    final totalPages = state.totalPages;
    final totalCount = state.totalCount;
    final perPage = state.perPage;

    final startItem = (currentPage - 1) * perPage + 1;
    final endItem = (currentPage * perPage) > totalCount ? totalCount : (currentPage * perPage);

    // Calculate visible page buttons
    final pageNumbers = <int>[];
    int startPage = (currentPage - 2).clamp(1, totalPages);
    int endPage = (currentPage + 2).clamp(1, totalPages);

    if (endPage - startPage < 4) {
      if (startPage == 1) {
        endPage = (startPage + 4).clamp(1, totalPages);
      } else if (endPage == totalPages) {
        startPage = (endPage - 4).clamp(1, totalPages);
      }
    }

    for (int i = startPage; i <= endPage; i++) {
      pageNumbers.add(i);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink900.withAlpha(6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Info
          Text(
            'Hiển thị $startItem – $endItem trên $totalCount tạp chí',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontFamily: 'Manrope',
            ),
          ),

          // Right: Page controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous button
              OutlinedButton.icon(
                onPressed: (currentPage > 1 && !state.isSearching)
                    ? () => _onPageChanged(currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left_rounded, size: 16),
                label: const Text('Trước', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 8),

              if (startPage > 1) ...[
                _buildPageNumberButton(1, currentPage, state.isSearching),
                if (startPage > 2)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('...', style: TextStyle(color: AppColors.textMuted)),
                  ),
              ],

              ...pageNumbers.map((p) => _buildPageNumberButton(p, currentPage, state.isSearching)),

              if (endPage < totalPages) ...[
                if (endPage < totalPages - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('...', style: TextStyle(color: AppColors.textMuted)),
                  ),
                _buildPageNumberButton(totalPages, currentPage, state.isSearching),
              ],

              const SizedBox(width: 8),
              // Next button
              OutlinedButton.icon(
                onPressed: (currentPage < totalPages && !state.isSearching)
                    ? () => _onPageChanged(currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded, size: 16),
                label: const Text('Sau', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumberButton(int page, int currentPage, bool isSearching) {
    final isSelected = page == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: (!isSelected && !isSearching) ? () => _onPageChanged(page) : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontFamily: 'Manrope',
            ),
          ),
        ),
      ),
    );
  }
}

class _JournalCardWidget extends StatefulWidget {
  final OpenAlexJournalModel journal;
  final VoidCallback? onConfigure;
  final VoidCallback? onViewJob;

  const _JournalCardWidget({
    super.key,
    required this.journal,
    this.onConfigure,
    this.onViewJob,
  });

  @override
  State<_JournalCardWidget> createState() => _JournalCardWidgetState();
}

class _JournalCardWidgetState extends State<_JournalCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final journal = widget.journal;
    final isAnalyzing = journal.analysisStatus == AnalysisStatus.analyzing;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? AppColors.primary
                : (isAnalyzing ? AppColors.primary.withAlpha(90) : AppColors.border),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? AppColors.primary.withAlpha(24)
                  : AppColors.ink900.withAlpha(6),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 6 : 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Title & Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Tooltip(
                    message: journal.title,
                    waitDuration: const Duration(milliseconds: 400),
                    child: Text(
                      journal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontFamily: 'Manrope',
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(journal),
              ],
            ),
            const SizedBox(height: 10),

            // Metadata Chips
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (journal.issnL != null)
                  _buildMetaChip(
                    icon: Icons.tag_rounded,
                    text: 'ISSN: ${journal.issnL}',
                    bgColor: AppColors.surfaceSoft,
                  ),
                if (journal.publisher != null)
                  _buildMetaChip(
                    icon: Icons.business_rounded,
                    text: journal.publisher!,
                    bgColor: AppColors.surfaceSoft,
                  ),
                _buildMetaChip(
                  icon: Icons.library_books_outlined,
                  text: '${journal.worksCount} bài báo',
                  bgColor: AppColors.surfaceSoft,
                ),
                _buildMetaChip(
                  icon: Icons.format_quote_rounded,
                  text: '${journal.citedByCount} trích dẫn',
                  bgColor: AppColors.surfaceSoft,
                ),
              ],
            ),

            const Spacer(),
            const Divider(height: 16, color: AppColors.border),

            // Action row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'OpenAlex ID: ${journal.openalexId.replaceAll("https://openalex.org/", "")}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isAnalyzing) ...[
                  OutlinedButton.icon(
                    onPressed: widget.onViewJob,
                    icon: const Icon(Icons.timeline_rounded, size: 14),
                    label: const Text('Xem tiến trình', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ] else ...[
                  ElevatedButton.icon(
                    onPressed: widget.onConfigure,
                    icon: const Icon(Icons.tune_rounded, size: 14),
                    label: Text(
                      journal.hasConfiguration ? 'Sửa cấu hình' : '+ Cấu hình',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String text,
    required Color bgColor,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OpenAlexJournalModel journal) {
    switch (journal.analysisStatus) {
      case AnalysisStatus.analyzing:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Đang phân tích',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue.shade800,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        );

      case AnalysisStatus.analyzed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_rounded,
                  size: 12, color: Colors.green.shade700),
              const SizedBox(width: 4),
              Text(
                'Đã phân tích',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade800,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
        );

      case AnalysisStatus.failed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Text(
            'Thất bại',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.red.shade800,
              fontFamily: 'Manrope',
            ),
          ),
        );

      case AnalysisStatus.notAnalyzed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Text(
            'Chưa phân tích',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.amber.shade900,
              fontFamily: 'Manrope',
            ),
          ),
        );
    }
  }
}

