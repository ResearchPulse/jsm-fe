import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../data/datasources/admin_api_client.dart';

class ProfilesReviewView extends StatefulWidget {
  final Function(int) onNavigateToTab;

  const ProfilesReviewView({super.key, required this.onNavigateToTab});

  @override
  State<ProfilesReviewView> createState() => _ProfilesReviewViewState();
}

class _ProfilesReviewViewState extends State<ProfilesReviewView> {
  final AdminApiClient _apiClient = AdminApiClient();
  List<Map<String, dynamic>> _profiles = [];
  String? _selectedJournalId;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
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
        if (list.isNotEmpty) {
          _selectedJournalId = list.first['journal_id']?.toString();
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

  Map<String, dynamic>? get _currentProfile {
    if (_profiles.isEmpty) return null;
    if (_selectedJournalId == null) return _profiles.first;
    return _profiles.firstWhere(
      (p) => p['journal_id']?.toString() == _selectedJournalId,
      orElse: () => _profiles.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _currentProfile;
    final stance = profile?['stance'] as Map<String, dynamic>?;
    final moves = profile?['cars_moves'] as Map<String, dynamic>?;
    final metrics = profile?['sentence_metrics'] as Map<String, dynamic>?;
    final exemplar = profile?['exemplar'] as Map<String, dynamic>?;

    final neutralStance = (stance?['neutral'] as num?)?.toDouble() ?? 0.64;
    final supportStance = (stance?['support'] as num?)?.toDouble() ?? 0.28;
    final contradictStance = (stance?['contradict'] as num?)?.toDouble() ?? 0.08;

    final moveTerritory = (moves?['territory'] as num?)?.toDouble() ?? 0.98;
    final moveNiche = (moves?['niche'] as num?)?.toDouble() ?? 0.92;
    final moveOccupying = (moves?['occupying'] as num?)?.toDouble() ?? 0.96;

    final meanLength = metrics?['mean_length'] ?? 24.6;
    final p10 = metrics?['p10'] ?? 12.0;
    final p50 = metrics?['p50'] ?? 23.5;
    final p90 = metrics?['p90'] ?? 38.2;
    final lexicalDensity = metrics?['lexical_density'] ?? 0.58;
    final hedges = metrics?['hedges_per_1k'] ?? 14.2;
    final boosters = metrics?['boosters_per_1k'] ?? 6.8;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
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
                    'Đánh giá các đặc trưng học thuật (Lập trường Stance, CARS Moves, Độ dài câu & Hedges) trước khi xuất bản thành chuẩn đối chiếu cho sinh viên.',
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
                    onPressed: _loadProfiles,
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Tải lại hồ sơ',
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
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
                    label: const Text('Xuất bản làm Tiêu chuẩn chuẩn hóa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green700,
                      foregroundColor: Colors.white,
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
                      onPressed: _loadProfiles,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else if (_profiles.isEmpty)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: Text(
                  'Chưa có hồ sơ phong cách nào được trích xuất. Vui lòng chạy phân tích một tạp chí trước.',
                  style: TextStyle(color: AppColors.textMuted, fontFamily: 'Manrope'),
                ),
              ),
            )
          else ...[
            // Journal Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.menu_book_rounded, size: 18, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Text(
                    'Tạp chí đang kiểm duyệt:',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Manrope'),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedJournalId,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Manrope'),
                        items: _profiles.map((p) {
                          final id = p['journal_id']?.toString() ?? '';
                          final name = p['journal_name'] ?? 'Tạp chí';
                          final count = p['paper_count'] ?? 0;
                          final issn = p['issn'] ?? 'N/A';
                          return DropdownMenuItem<String>(
                            value: id,
                            child: Text('$name (ISSN: $issn • $count bài)', maxLines: 1, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedJournalId = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3 Feature Cards Layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column 1: Stance Analysis
                Expanded(
                  child: _buildSectionCard(
                    title: 'Phân Bố Lập Trường (Stance)',
                    badgeText: 'NLP Classifier',
                    description: 'Thái độ của tác giả đối với các nghiên cứu tiền nhiệm trong bài viết.',
                    children: [
                      _buildMetricBar(
                        label: 'Trung lập (Neutral / Objective)',
                        percent: neutralStance,
                        color: AppColors.primary,
                        desc: '${(neutralStance * 100).toInt()}% câu trích dẫn mang tính trung lập, tường thuật khách quan.',
                      ),
                      const SizedBox(height: 14),
                      _buildMetricBar(
                        label: 'Ủng hộ / Đồng thuận (Support)',
                        percent: supportStance,
                        color: AppColors.green700,
                        desc: '${(supportStance * 100).toInt()}% củng cố và dựa trên nền tảng phương pháp có sẵn.',
                      ),
                      const SizedBox(height: 14),
                      _buildMetricBar(
                        label: 'Phản biện / Bất đồng (Contradict)',
                        percent: contradictStance,
                        color: const Color(0xFFD97706),
                        desc: '${(contradictStance * 100).toInt()}% chỉ ra mâu thuẫn hoặc điểm chưa hoàn thiện.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Column 2: CARS Rhetorical Moves
                Expanded(
                  child: _buildSectionCard(
                    title: 'Cấu Trúc Lập Luận (CARS Moves)',
                    badgeText: 'Swales Model',
                    description: 'Tỷ lệ xuất hiện các bước lập luận kinh điển ở phần Mở đầu (Introduction).',
                    children: [
                      _buildMetricBar(
                        label: 'Move 1: Thiết lập lãnh địa (Territory)',
                        percent: moveTerritory,
                        color: AppColors.primary,
                        desc: '${(moveTerritory * 100).toInt()}% bài báo mở đầu bằng việc nêu tầm quan trọng của chủ đề.',
                      ),
                      const SizedBox(height: 14),
                      _buildMetricBar(
                        label: 'Move 2: Xác lập khoảng trống (Niche)',
                        percent: moveNiche,
                        color: const Color(0xFF7C3AED),
                        desc: '${(moveNiche * 100).toInt()}% có bước chỉ ra khoảng trống tri thức hoặc bài toán chưa giải.',
                      ),
                      const SizedBox(height: 14),
                      _buildMetricBar(
                        label: 'Move 3: Chiếm lĩnh khoảng trống (Occupying)',
                        percent: moveOccupying,
                        color: const Color(0xFF0D9488),
                        desc: '${(moveOccupying * 100).toInt()}% trình bày rõ giải pháp và đóng góp của công trình hiện tại.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Lexical & Sentence Metrics Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                      const Text(
                        'Chỉ Số Từ Vựng & Độ Dài Câu Văn (Sentence & Lexical Metrics)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Manrope',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoft,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Text(
                          'Chuẩn Đối Sánh',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Manrope'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Định lượng phân phối độ dài câu theo phân vị (P10 - P90) và mật độ từ vựng học thuật.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontFamily: 'Manrope'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildMetricCard('ĐỘ DÀI CÂU TRUNG BÌNH', '$meanLength từ', 'P50 chuẩn: $p50 từ', Icons.format_align_left_rounded),
                      const SizedBox(width: 16),
                      _buildMetricCard('DẢI PHÂN VỊ (P10 - P90)', '$p10 - $p90 từ', 'Ngưỡng khuyến nghị', Icons.stacked_bar_chart_rounded),
                      const SizedBox(width: 16),
                      _buildMetricCard('MẬT ĐỘ TỪ VỰNG (LEXICAL DENSITY)', '${((lexicalDensity as num) * 100).toInt()}%', 'Content words / Total', Icons.spellcheck_rounded),
                      const SizedBox(width: 16),
                      _buildMetricCard('TỪ CẨN TRỌNG (HEDGES / 1K)', '$hedges / 1k từ', 'may, suggest, likely', Icons.psychology_outlined),
                      const SizedBox(width: 16),
                      _buildMetricCard('TỪ KHẲNG ĐỊNH (BOOSTERS / 1K)', '$boosters / 1k từ', 'clearly, demonstrate', Icons.auto_awesome_rounded),
                    ],
                  ),
                  if (exemplar != null && exemplar['doi'] != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.article_outlined, size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Bài báo mẫu chứng cứ: ${exemplar['title']} (${exemplar['doi']})',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Manrope'),
                                ),
                              ),
                            ],
                          ),
                          if (exemplar['sentence'] != null && exemplar['sentence'].toString().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 28),
                              child: Text(
                                '“${exemplar['sentence']}”',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.textPrimary,
                                  fontFamily: 'Manrope',
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ],
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

  Widget _buildSectionCard({
    required String title,
    required String badgeText,
    required String description,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Manrope'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildMetricBar({
    required String label,
    required double percent,
    required Color color,
    required String desc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Manrope'),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color, fontFamily: 'Manrope'),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: AppColors.surfaceSoft,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Manrope'),
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, String sub, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSubtle,
                      fontFamily: 'Manrope',
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: 'Manrope',
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Manrope'),
            ),
          ],
        ),
      ),
    );
  }
}
