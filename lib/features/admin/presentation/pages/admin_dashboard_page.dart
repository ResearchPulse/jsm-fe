import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../views/journals_view.dart';
import '../views/style_and_corpus_view.dart';
import '../views/system_and_debug_view.dart';
import '../widgets/admin_header.dart';
import '../widgets/admin_sidebar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;
  String? _targetJournalIdForProfile;
  int _styleCorpusSubTab = 0;
  int _systemDebugSubTab = 0;

  void _navigateToTab(int index, {String? journalId, int? subTabIndex}) {
    setState(() {
      _selectedIndex = index;
      if (journalId != null) {
        _targetJournalIdForProfile = journalId;
      }
      if (subTabIndex != null) {
        if (index == 1) _styleCorpusSubTab = subTabIndex;
        if (index == 2) _systemDebugSubTab = subTabIndex;
      }
    });
  }

  void _showTriggerAnalysisDialog() {
    final journalController = TextEditingController();
    int yearStart = 2021;
    int yearEnd = 2024;
    double targetPapers = 200;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // --ds-radius-panel
              ),
              title: const Text(
                'Kích hoạt Khai phá Tạp chí',
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
                      'Tạo tác vụ chạy nền để cào bài, bóc tách cấu trúc bằng Grobid và trích xuất hồ sơ phong cách.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontFamily: 'Manrope'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Mã ISSN hoặc Tên tạp chí', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Manrope')),
                    const SizedBox(height: 6),
                    TextField(
                      controller: journalController,
                      decoration: const InputDecoration(
                        hintText: 'Ví dụ: 0098-5589 hoặc IEEE TSE',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Từ năm', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Manrope')),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                initialValue: yearStart,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                                items: [2018, 2019, 2020, 2021, 2022].map((y) {
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
                              const Text('Đến năm', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Manrope')),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                initialValue: yearEnd,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                                items: [2023, 2024, 2025, 2026].map((y) {
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Số lượng bài báo mục tiêu', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Manrope')),
                        Text(
                          '${targetPapers.toInt()} bài',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontFamily: 'Manrope'),
                        ),
                      ],
                    ),
                    Slider(
                      value: targetPapers,
                      min: 50,
                      max: 500,
                      divisions: 9,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setModalState(() => targetPapers = val),
                    ),
                  ],
                ),
              ),
              actions: [
                OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Hủy bỏ'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _navigateToTab(2, subTabIndex: 0); // Navigate to Tab 2 (Job Monitor logs)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã kích hoạt tác vụ phân tích tạp chí thành công.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Bắt đầu phân tích'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActiveView() {
    switch (_selectedIndex) {
      case 0:
        return JournalsView(
          onNavigateToTab: _navigateToTab,
          onTriggerNewAnalysis: _showTriggerAnalysisDialog,
        );
      case 1:
        return StyleAndCorpusView(
          onNavigateToTab: _navigateToTab,
          selectedJournalId: _targetJournalIdForProfile,
          initialSubTabIndex: _styleCorpusSubTab,
        );
      case 2:
        return SystemAndDebugView(
          onNavigateToTab: _navigateToTab,
          onTriggerNewAnalysis: _showTriggerAnalysisDialog,
          initialSubTabIndex: _systemDebugSubTab,
        );
      default:
        return JournalsView(
          onNavigateToTab: _navigateToTab,
          onTriggerNewAnalysis: _showTriggerAnalysisDialog,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Sidebar on the left
          AdminSidebar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _navigateToTab,
            isCollapsed: _isSidebarCollapsed,
            onToggleCollapse: () {
              setState(() {
                _isSidebarCollapsed = !_isSidebarCollapsed;
              });
            },
          ),

          // Main Content Area (Header + Subview)
          Expanded(
            child: Column(
              children: [
                AdminHeader(
                  selectedIndex: _selectedIndex,
                  onNewJobPressed: _showTriggerAnalysisDialog,
                ),
                Expanded(
                  child: _buildActiveView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
