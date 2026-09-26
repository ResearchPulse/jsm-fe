import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/datasources/admin_api_client.dart';
import '../widgets/style_radar_chart.dart';

class ProfilesReviewView extends StatefulWidget {
  final Function(int) onNavigateToTab;
  final String? selectedJournalId;

  const ProfilesReviewView({
    super.key,
    required this.onNavigateToTab,
    this.selectedJournalId,
  });

  @override
  State<ProfilesReviewView> createState() => _ProfilesReviewViewState();
}

class _ProfilesReviewViewState extends State<ProfilesReviewView> {
  final AdminApiClient _apiClient = AdminApiClient();
  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = true;
  String? _error;

  // Selected Journal IDs for comparison (1 to 3 items)
  List<String> _selectedCompareIds = [];
  static const List<Color> _compareColors = [
    Color(0xFF0071BC), // Primary Brand Blue
    Color(0xFF7C3AED), // Iris Purple
    Color(0xFFD97706), // Amber Orange
  ];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  @override
  void didUpdateWidget(covariant ProfilesReviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedJournalId != null &&
        widget.selectedJournalId != oldWidget.selectedJournalId &&
        _profiles.any((p) => p['journal_id']?.toString() == widget.selectedJournalId)) {
      final jId = widget.selectedJournalId!;
      if (!_selectedCompareIds.contains(jId)) {
        setState(() {
          if (_selectedCompareIds.length >= 3) {
            _selectedCompareIds[0] = jId;
          } else {
            _selectedCompareIds.add(jId);
          }
        });
      }
    }
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _apiClient.getStyleProfiles();
      if (!mounted) return;
      setState(() {
        _profiles = list;

        // Initialize compare selection (up to 2 by default, or widget selected)
        if (_selectedCompareIds.isEmpty && list.isNotEmpty) {
          if (widget.selectedJournalId != null &&
              list.any((p) => p['journal_id']?.toString() == widget.selectedJournalId)) {
            final other = list.firstWhere(
              (p) => p['journal_id']?.toString() != widget.selectedJournalId,
              orElse: () => list.first,
            );
            _selectedCompareIds = [
              widget.selectedJournalId!,
              if (other['journal_id']?.toString() != widget.selectedJournalId)
                other['journal_id']?.toString() ?? '',
            ].where((id) => id.isNotEmpty).toList();
          } else {
            _selectedCompareIds = list
                .take(2)
                .map((p) => p['journal_id']?.toString() ?? '')
                .where((id) => id.isNotEmpty)
                .toList();
          }
        }

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

  void _addJournalSlot() {
    if (_selectedCompareIds.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ có thể so sánh tối đa 3 tạp chí cùng một lúc.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String? nextId;
    for (final p in _profiles) {
      final pid = p['journal_id']?.toString();
      if (pid != null && !_selectedCompareIds.contains(pid)) {
        nextId = pid;
        break;
      }
    }
    nextId ??= _profiles.first['journal_id']?.toString();

    if (nextId != null) {
      setState(() {
        _selectedCompareIds.add(nextId!);
      });
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
          _buildHeader(),
          const SizedBox(height: 24),

          // State Handling
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(64),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            _buildErrorState()
          else if (_profiles.isEmpty)
            _buildEmptyState()
          else
            _buildComparisonView(),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────
  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;

        final titleCol = const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kiểm Duyệt Hồ Sơ Phong Cách Tạp Chí',
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
              'So sánh và đánh giá phong cách học thuật qua biểu đồ Radar đa chiều và bảng chỉ số chi tiết.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
                fontFamily: 'Manrope',
              ),
            ),
          ],
        );

        final controlsWrap = Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              onPressed: _loadProfiles,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Tải lại hồ sơ',
              color: AppColors.primary,
            ),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Hồ sơ phong cách đã được xuất bản làm tiêu chuẩn đối chiếu cho sinh viên.'),
                    backgroundColor: AppColors.green700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.verified_rounded, size: 18),
              label: const Text('Xuất bản Tiêu chuẩn'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleCol,
              const SizedBox(height: 12),
              controlsWrap,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleCol),
            const SizedBox(width: 16),
            controlsWrap,
          ],
        );
      },
    );
  }

  // ── Unified Style & Comparison View ──────────────────────────────
  Widget _buildComparisonView() {
    final selectedProfiles = _selectedCompareIds.map((id) {
      return _profiles.firstWhere(
        (p) => p['journal_id']?.toString() == id,
        orElse: () => _profiles.first,
      );
    }).toList();

    final datasets = <RadarDataset>[];
    for (int i = 0; i < selectedProfiles.length; i++) {
      final color = _compareColors[i % _compareColors.length];
      datasets.add(RadarDataset.fromProfile(selectedProfiles[i], color));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 1000;
        final radarCard = Container(
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
                  Row(
                    children: [
                      const Icon(Icons.radar_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        selectedProfiles.length == 1
                            ? 'Biểu Đồ Radar Phong Cách Học Thuật'
                            : 'Biểu Đồ Radar So Sánh Đa Chiều',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '6 Trục chuẩn hóa 0–100%',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StyleRadarChart(
                datasets: datasets,
                height: 340,
                showLegend: true,
              ),
            ],
          ),
        );

        final insightsCard = _buildKeyInsightsCard(selectedProfiles);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Dropdown Selectors Bar with (+) Button
            _buildCompareSelectorBar(),
            const SizedBox(height: 24),

            // 2. Upper Block: Radar Chart (60%) + Key Insights Card (40%)
            if (isCompact) ...[
              radarCard,
              const SizedBox(height: 20),
              insightsCard,
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: radarCard),
                  const SizedBox(width: 20),
                  Expanded(flex: 4, child: insightsCard),
                ],
              ),
            ],
            const SizedBox(height: 28),

            // 3. Lower Block: Side-by-Side Comparison Cards
            Row(
              children: [
                const Icon(Icons.view_column_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  selectedProfiles.length == 1
                      ? 'Chi Tiết Chỉ Số Tạp Chí'
                      : 'Bảng So Sánh Chỉ Số Từng Tạp Chí (${selectedProfiles.length} tạp chí)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSideBySideCards(selectedProfiles),
          ],
        );
      },
    );
  }

  // ── Dropdown Selectors Bar with (+) Button ────────────────────────
  Widget _buildCompareSelectorBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Tạp chí so sánh (${_selectedCompareIds.length}/3):',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
              Text(
                _selectedCompareIds.length == 1
                    ? 'Đang xem đơn lẻ • Bấm (+) để thêm tạp chí so sánh'
                    : 'Đang so sánh ${_selectedCompareIds.length} tạp chí song song',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSubtle, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < _selectedCompareIds.length; i++) ...[
                if (i > 0) const SizedBox(width: 14),
                Expanded(
                  child: _buildDropdownSlot(i, _selectedCompareIds[i], _profiles),
                ),
              ],
              if (_selectedCompareIds.length < 3) ...[
                const SizedBox(width: 14),
                _buildAddJournalButton(),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddJournalButton() {
    return Tooltip(
      message: 'Thêm tạp chí so sánh (tối đa 3)',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _addJournalSlot,
          borderRadius: BorderRadius.circular(22),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.blue50,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withAlpha(160), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(20),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 24,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSlot(int index, String currentId, List<Map<String, dynamic>> profiles) {
    final color = _compareColors[index % _compareColors.length];
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(160), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'Tạp chí ${index + 1}',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontFamily: 'Manrope',
                ),
              ),
              const Spacer(),
              if (_selectedCompareIds.length > 1)
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCompareIds.removeAt(index);
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.close_rounded, size: 16, color: AppColors.textSubtle),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: profiles.any((p) => p['journal_id']?.toString() == currentId)
                  ? currentId
                  : (profiles.isNotEmpty ? profiles.first['journal_id']?.toString() : null),
              isExpanded: true,
              isDense: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 20),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Manrope',
              ),
              items: profiles.map((p) {
                final id = p['journal_id']?.toString() ?? '';
                final name = p['journal_name'] ?? 'Tạp chí';
                final issn = p['issn'] ?? 'N/A';
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text(
                    '$name (ISSN: $issn)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (newVal) {
                if (newVal != null) {
                  setState(() {
                    _selectedCompareIds[index] = newVal;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Key Insights / Highlights Card ───────────────────────────────
  Widget _buildKeyInsightsCard(List<Map<String, dynamic>> profiles) {
    if (profiles.isEmpty) return const SizedBox.shrink();

    // 1. Single Journal Insights
    if (profiles.length == 1) {
      final p = profiles.first;
      final title = p['journal_name'] ?? 'Tạp chí';
      final metrics = p['sentence_metrics'] as Map<String, dynamic>?;
      final stance = p['stance'] as Map<String, dynamic>?;

      final meanLen = (metrics?['mean_length'] as num?)?.toDouble() ?? 22.0;
      final hedges = (metrics?['hedges_per_1k'] as num?)?.toDouble() ?? 15.0;
      final boosters = (metrics?['boosters_per_1k'] as num?)?.toDouble() ?? 10.0;
      final neutral = (stance?['neutral'] as num?)?.toDouble() ?? 0.65;
      final lexDensity = (metrics?['lexical_density'] as num?)?.toDouble() ?? 0.55;

      return Container(
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
            const Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 18, color: Color(0xFFD97706)),
                SizedBox(width: 8),
                Text(
                  'Tổng Quan Phong Cách Tạp Chí',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Các chỉ số học thuật cốt lõi của $title:',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Manrope'),
            ),
            const SizedBox(height: 18),
            _buildInsightItem(
              icon: Icons.short_text_rounded,
              color: _compareColors[0],
              title: 'Độ dài câu trung bình: ${meanLen.toStringAsFixed(1)} từ',
              description: 'Văn phong có độ phức hợp cân bằng, mật độ từ vựng đạt ${(lexDensity * 100).toInt()}%.',
            ),
            const SizedBox(height: 14),
            _buildInsightItem(
              icon: Icons.shield_outlined,
              color: _compareColors[0],
              title: 'Cân bằng Rào đón & Khẳng định',
              description:
                  'Sử dụng ${hedges.toStringAsFixed(1)} từ rào đón/1k từ và ${boosters.toStringAsFixed(1)} từ khẳng định/1k từ, thể hiện giọng điệu khoa học chuẩn mực.',
            ),
            const SizedBox(height: 14),
            _buildInsightItem(
              icon: Icons.balance_rounded,
              color: _compareColors[0],
              title: 'Lập trường trung lập: ${(neutral * 100).toInt()}%',
              description: 'Giữ tính khách quan cao trong phần trình bày kết quả và thảo luận.',
            ),
          ],
        ),
      );
    }

    // 2. Multi-Journal Divergences
    final lengths = profiles.map((p) {
      final m = p['sentence_metrics'] as Map<String, dynamic>?;
      return (m?['mean_length'] as num?)?.toDouble() ?? 22.0;
    }).toList();

    final hedges = profiles.map((p) {
      final m = p['sentence_metrics'] as Map<String, dynamic>?;
      return (m?['hedges_per_1k'] as num?)?.toDouble() ?? 15.0;
    }).toList();

    final neutrals = profiles.map((p) {
      final s = p['stance'] as Map<String, dynamic>?;
      return (s?['neutral'] as num?)?.toDouble() ?? 0.65;
    }).toList();

    final maxLenIdx = lengths.indexOf(lengths.reduce((a, b) => a > b ? a : b));
    final minLenIdx = lengths.indexOf(lengths.reduce((a, b) => a < b ? a : b));
    final lenDiff = (lengths[maxLenIdx] - lengths[minLenIdx]).toStringAsFixed(1);

    final maxHedgeIdx = hedges.indexOf(hedges.reduce((a, b) => a > b ? a : b));
    final minHedgeIdx = hedges.indexOf(hedges.reduce((a, b) => a < b ? a : b));

    final maxNeutralIdx = neutrals.indexOf(neutrals.reduce((a, b) => a > b ? a : b));

    return Container(
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
          const Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 18, color: Color(0xFFD97706)),
              SizedBox(width: 8),
              Text(
                'Điểm Nhấn Phong Cách So Sánh',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Tổng hợp các sai biệt phong cách đáng chú ý nhất giữa các tạp chí:',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 18),

          // Insight Item 1: Sentence Length Divergence
          _buildInsightItem(
            icon: Icons.short_text_rounded,
            color: _compareColors[maxLenIdx % _compareColors.length],
            title: 'Chênh lệch độ dài câu: $lenDiff từ/câu',
            description:
                '${profiles[maxLenIdx]['journal_name']} sử dụng câu dài hơn (${lengths[maxLenIdx].toStringAsFixed(1)} từ), trong khi ${profiles[minLenIdx]['journal_name']} có cấu trúc câu súc tích hơn (${lengths[minLenIdx].toStringAsFixed(1)} từ).',
          ),
          const SizedBox(height: 14),

          // Insight Item 2: Hedging Divergence
          _buildInsightItem(
            icon: Icons.shield_outlined,
            color: _compareColors[maxHedgeIdx % _compareColors.length],
            title: 'Mức độ rào đón (Hedging)',
            description:
                '${profiles[maxHedgeIdx]['journal_name']} có xu hướng dùng từ rào đón thận trọng cao nhất (${hedges[maxHedgeIdx].toStringAsFixed(1)}/1k từ), cao hơn ${profiles[minHedgeIdx]['journal_name']} (${hedges[minHedgeIdx].toStringAsFixed(1)}/1k từ).',
          ),
          const SizedBox(height: 14),

          // Insight Item 3: Stance Divergence
          _buildInsightItem(
            icon: Icons.balance_rounded,
            color: _compareColors[maxNeutralIdx % _compareColors.length],
            title: 'Lập trường trung lập khách quan',
            description:
                '${profiles[maxNeutralIdx]['journal_name']} đạt tỷ lệ câu trung tính cao nhất (${(neutrals[maxNeutralIdx] * 100).toStringAsFixed(0)}%), thể hiện văn phong khoa học chuẩn mực và tránh áp đặt luận điểm.',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                    fontFamily: 'Manrope',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Side-by-Side Comparison Cards ─────────────────────────────────
  Widget _buildSideBySideCards(List<Map<String, dynamic>> profiles) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (profiles.length == 1) {
          final p = profiles.first;
          final color = _compareColors[0];
          return Container(
            constraints: const BoxConstraints(maxWidth: 680),
            child: _buildSingleCompareCard(p, color),
          );
        }

        const minCardWidth = 320.0;
        final availableWidth = constraints.maxWidth;
        final calculatedWidth = (availableWidth - ((profiles.length - 1) * 16)) / profiles.length;
        final needsScroll = calculatedWidth < minCardWidth;
        final cardWidth = needsScroll ? minCardWidth : calculatedWidth;

        final rowContent = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: profiles.asMap().entries.map((entry) {
            final idx = entry.key;
            final p = entry.value;
            final color = _compareColors[idx % _compareColors.length];

            return Container(
              width: cardWidth,
              margin: EdgeInsets.only(right: idx < profiles.length - 1 ? 16 : 0),
              child: _buildSingleCompareCard(p, color),
            );
          }).toList(),
        );

        if (needsScroll) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: rowContent,
          );
        }
        return rowContent;
      },
    );
  }

  Widget _buildSingleCompareCard(Map<String, dynamic> profile, Color color) {
    final title = profile['journal_name'] ?? 'Tạp chí';
    final issn = profile['issn'] ?? 'N/A';
    final count = profile['paper_count'] ?? 0;
    final metrics = profile['sentence_metrics'] as Map<String, dynamic>?;
    final stance = profile['stance'] as Map<String, dynamic>?;
    final moves = profile['cars_moves'] as Map<String, dynamic>?;
    final exemplar = profile['exemplar'] as Map<String, dynamic>?;

    final meanLen = metrics?['mean_length'] ?? 24.6;
    final p10 = metrics?['p10'] ?? 12.0;
    final p50 = metrics?['p50'] ?? 23.5;
    final p90 = metrics?['p90'] ?? 38.2;
    final lexDensity = metrics?['lexical_density'] ?? 0.58;
    final hedges = metrics?['hedges_per_1k'] ?? 14.2;
    final boosters = metrics?['boosters_per_1k'] ?? 6.8;

    final neutral = (stance?['neutral'] as num?)?.toDouble() ?? 0.64;
    final support = (stance?['support'] as num?)?.toDouble() ?? 0.28;
    final contradict = (stance?['contradict'] as num?)?.toDouble() ?? 0.08;

    final moveTerritory = (moves?['territory'] as num?)?.toDouble() ?? 0.98;
    final moveNiche = (moves?['niche'] as num?)?.toDouble() ?? 0.92;
    final moveOccupying = (moves?['occupying'] as num?)?.toDouble() ?? 0.96;

    final exemplarSentence = exemplar?['sentence'] ??
        'We present an extensive empirical benchmark across multiple domains to validate our proposed framework.';
    final exemplarDoi = exemplar?['doi'] ?? 'https://doi.org/10.1371/journal.pone.0297921';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(120), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Accent Color Bar with Journal Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: color.withAlpha(60))),
            ),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ISSN: $issn • $count bài phân tích',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontFamily: 'Manrope'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Thống kê câu
                const Text(
                  '1. Độ dài câu & Phân vị (P10 / P50 / P90)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Độ dài trung bình:', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          Text(
                            '$meanLen từ/câu',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('P10 (ngắn): $p10', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          Text('P50 (trung vị): $p50', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          Text('P90 (dài): $p90', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Từ vựng & Mức rào đón
                const Text(
                  '2. Mật độ từ vựng & Rào đón / Khẳng định',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mật độ từ vựng', style: TextStyle(fontSize: 10, color: AppColors.textSubtle)),
                            const SizedBox(height: 4),
                            Text('${(lexDensity * 100).toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Hedges / 1k từ', style: TextStyle(fontSize: 10, color: AppColors.textSubtle)),
                            const SizedBox(height: 4),
                            Text('$hedges', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Boosters / 1k', style: TextStyle(fontSize: 10, color: AppColors.textSubtle)),
                            const SizedBox(height: 4),
                            Text('$boosters', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Lập trường (Stance)
                const Text(
                  '3. Phân bố lập trường (Stance Ratio)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 10,
                    child: Row(
                      children: [
                        Expanded(
                          flex: (neutral * 100).toInt(),
                          child: Container(color: AppColors.primary),
                        ),
                        Expanded(
                          flex: (support * 100).toInt(),
                          child: Container(color: AppColors.green700),
                        ),
                        Expanded(
                          flex: (contradict * 100).toInt(),
                          child: Container(color: AppColors.red700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Trung lập ${(neutral * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: AppColors.primary)),
                    Text('Ủng hộ ${(support * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: AppColors.green700)),
                    Text('Phản bác ${(contradict * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: AppColors.red700)),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Khung CARS Moves
                const Text(
                  '4. Độ phủ mô hình CARS Moves',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                _buildMiniMoveBar('Move 1: Khẳng định lãnh địa', moveTerritory, color),
                const SizedBox(height: 6),
                _buildMiniMoveBar('Move 2: Chỉ ra lỗ hổng nghiên cứu', moveNiche, color),
                const SizedBox(height: 6),
                _buildMiniMoveBar('Move 3: Chiếm lĩnh & Đóng góp', moveOccupying, color),
                const SizedBox(height: 16),

                // 5. Câu văn mẫu (Exemplar)
                const Text(
                  '5. Câu văn mẫu mở đầu (Intro Exemplar)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '“$exemplarSentence”',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              exemplarDoi,
                              style: const TextStyle(fontSize: 10, color: AppColors.primary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: exemplarSentence));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đã sao chép câu văn mẫu vào clipboard.'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.copy_rounded, size: 14, color: AppColors.textSubtle),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMoveBar(String label, double val, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
            Text('${(val * 100).toInt()}%', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: val.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: AppColors.surfaceSoft,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ── Common Sub-widgets ───────────────────────────────────────────
  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 36),
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Manrope')),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _loadProfiles,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Center(
        child: Text(
          'Chưa có hồ sơ phong cách nào được trích xuất. Vui lòng chạy phân tích một tạp chí trước.',
          style: TextStyle(color: AppColors.textMuted, fontFamily: 'Manrope'),
        ),
      ),
    );
  }
}
