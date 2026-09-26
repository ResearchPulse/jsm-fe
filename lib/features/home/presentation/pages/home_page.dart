import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../student_manuscript_checker/presentation/pages/student_manuscript_checker_page.dart';
import '../widgets/user_header.dart';
import '../widgets/user_sidebar.dart';
import '../../../../core/localization/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isSidebarCollapsed = false;

  void _navigateToTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildActiveTab() {
    switch (_selectedIndex) {
      case 0:
        return const StudentManuscriptCheckerPage(showAppBar: false);
      case 1:
        return _buildJournalRecommendationsPlaceholder();
      case 2:
        return _buildHistoryPlaceholder();
      default:
        return const StudentManuscriptCheckerPage(showAppBar: false);
    }
  }

  Widget _buildJournalRecommendationsPlaceholder() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Icon(
                    Icons.recommend_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.journalRecTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.journalRecDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFamily: 'Manrope',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _navigateToTab(0),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(l10n.backToManuscriptChecker),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryPlaceholder() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.sidebarBorder),
                ),
                child: const Center(
                  child: Icon(
                    Icons.history_rounded,
                    size: 32,
                    color: AppColors.sidebarIconInactive,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.evalHistoryTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.evalHistoryDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  fontFamily: 'Manrope',
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _navigateToTab(0),
                icon: const Icon(Icons.rate_review_rounded, size: 16),
                label: Text(l10n.checkManuscriptNow),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const double _minDashboardWidth = 1024.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 1100;
        final effectiveCollapsed = isNarrow || _isSidebarCollapsed;

        final scaffold = Scaffold(
          backgroundColor: AppColors.background,
          body: Row(
            children: [
              // User Sidebar
              UserSidebar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _navigateToTab,
                isCollapsed: effectiveCollapsed,
                onToggleCollapse: () {
                  setState(() {
                    _isSidebarCollapsed = !_isSidebarCollapsed;
                  });
                },
              ),

              // Main content area
              Expanded(
                child: Column(
                  children: [
                    UserHeader(
                      selectedIndex: _selectedIndex,
                    ),
                    Expanded(
                      child: _buildActiveTab(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        if (constraints.maxWidth < _minDashboardWidth) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _minDashboardWidth,
              height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
              child: scaffold,
            ),
          );
        }

        return scaffold;
      },
    );
  }
}
