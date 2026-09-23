import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../views/configurations_view.dart';
import '../views/job_monitor_view.dart';
import '../views/journals_view.dart';
import '../views/overview_view.dart';
import '../views/profiles_review_view.dart';
import '../views/settings_view.dart';
import '../views/snapshots_view.dart';
import '../../../users/presentation/views/users_view.dart';
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

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
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
                'Analyze journal',
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
                      'Queue a background pipeline job to extract style profiles and synthesis evidence.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontFamily: 'Manrope'),
                    ),
                    const SizedBox(height: 20),
                    const Text('Journal ISSN or name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Manrope')),
                    const SizedBox(height: 6),
                    TextField(
                      controller: journalController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. 0098-5589 or IEEE TSE',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start year', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Manrope')),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                value: yearStart,
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
                              const Text('End year', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Manrope')),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<int>(
                                value: yearEnd,
                                decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                                items: [2023, 2024, 2025].map((y) {
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
                        const Text('Target paper sample count', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, fontFamily: 'Manrope')),
                        Text(
                          '${targetPapers.toInt()} papers',
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
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _navigateToTab(3); // Navigate to Job Monitor
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Analysis job queued successfully.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Start analysis'),
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
        return OverviewView(
          onNavigateToTab: _navigateToTab,
          onTriggerNewAnalysis: _showTriggerAnalysisDialog,
        );
      case 1:
        return JournalsView(
          onNavigateToTab: _navigateToTab,
        );
      case 2:
        return ConfigurationsView(
          onNavigateToTab: _navigateToTab,
          onTriggerNewAnalysis: _showTriggerAnalysisDialog,
        );
      case 3:
        return JobMonitorView(
          onNavigateToTab: _navigateToTab,
          onTriggerNewAnalysis: _showTriggerAnalysisDialog,
        );
      case 4:
        return SnapshotsView(
          onNavigateToTab: _navigateToTab,
        );
      case 5:
        return ProfilesReviewView(
          onNavigateToTab: _navigateToTab,
        );
      case 6:
        return const SettingsView();
      case 7:
        return const UsersView();
      default:
        return OverviewView(
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
