import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

import '../../../../core/localization/app_localizations.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      width: isCollapsed ? 76 : 260,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(
          right: BorderSide(color: AppColors.sidebarBorder, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBrandHeader(),
          const Divider(color: AppColors.sidebarBorder, height: 1),

          // Menu navigation: 3 Core Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.auto_stories_outlined,
                  activeIcon: Icons.auto_stories_rounded,
                  title: context.l10n.navJournalsCenter,
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  index: 1,
                  icon: Icons.psychology_outlined,
                  activeIcon: Icons.psychology_rounded,
                  title: context.l10n.navNlpProfiles,
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  index: 2,
                  icon: Icons.tune_outlined,
                  activeIcon: Icons.tune_rounded,
                  title: context.l10n.navSystemTechnical,
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.sidebarBorder, height: 1),
          _buildBottomArea(context),
        ],
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 18 : 22),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          // Logo "H" in blue rounded square as in screenshot
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0071BC), Color(0xFF2596BE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'H',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                  fontFamily: 'Manrope',
                ),
              ),
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'HyperData Lab',
                style: TextStyle(
                  color: Color(0xFF122331),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Manrope',
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String title,
  }) {
    final bool isSelected = selectedIndex == index;

    Widget item = Container(
      margin: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 10 : 14,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.sidebarActive : Colors.transparent, // #e1f0fa soft light blue
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => onDestinationSelected(index),
        borderRadius: BorderRadius.circular(12),
        hoverColor: isSelected ? null : AppColors.sidebarHover,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 14 : 14,
            vertical: 12,
          ),
          child: Row(
            mainAxisAlignment:
                isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected
                    ? AppColors.sidebarActiveIcon // #0071bc
                    : AppColors.sidebarIconInactive, // #64748b
                size: 21,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.sidebarActiveText // #0071bc
                          : AppColors.sidebarTextInactive, // #334155
                      fontSize: 14,
                      fontFamily: 'Manrope',
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (isCollapsed) {
      return Tooltip(
        message: title,
        preferBelow: false,
        child: item,
      );
    }
    return item;
  }

  Widget _buildBottomArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCollapsed ? 10 : 14),
      child: Column(
        children: [
          if (!isCollapsed) ...[
            InkWell(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.sidebarBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.sidebarIconInactive),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.backToHome,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.sidebarTextInactive,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          IconButton(
            onPressed: onToggleCollapse,
            icon: Icon(
              isCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
              color: AppColors.sidebarIconInactive,
              size: 20,
            ),
            tooltip: isCollapsed ? context.l10n.expandSidebar : context.l10n.collapseSidebar,
            style: IconButton.styleFrom(
              hoverColor: AppColors.sidebarHover,
            ),
          ),
        ],
      ),
    );
  }
}
