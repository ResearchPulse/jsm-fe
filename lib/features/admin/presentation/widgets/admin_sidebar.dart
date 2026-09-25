import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

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

          // Menu navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: [
                _buildSectionHeader('KHÔNG GIAN GIẢNG VIÊN'),
                _buildNavItem(
                  index: 0,
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description_rounded,
                  title: 'Bản Thảo Của Tôi',
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.article_outlined,
                  activeIcon: Icons.article_rounded,
                  title: 'Kho Bài Báo Khoa Học',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.tune_outlined,
                  activeIcon: Icons.tune_rounded,
                  title: 'Cấu Hình Tạp Chí',
                ),
                const SizedBox(height: 24),

                _buildSectionHeader('THẨM ĐỊNH PHẢN BIỆN'),
                _buildNavItem(
                  index: 3,
                  icon: Icons.fact_check_outlined,
                  activeIcon: Icons.fact_check_rounded,
                  title: 'Hàng Đợi Thẩm Định',
                ),
                _buildNavItem(
                  index: 4,
                  icon: Icons.layers_outlined,
                  activeIcon: Icons.layers_rounded,
                  title: 'Kho Lưu Trữ Snapshot',
                ),
                _buildNavItem(
                  index: 5,
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics_rounded,
                  title: 'Hồ Sơ Phong Cách',
                ),
                const SizedBox(height: 24),

                _buildSectionHeader('R&D / PIPELINE & AI'),
                _buildNavItem(
                  index: 8,
                  icon: Icons.science_outlined,
                  activeIcon: Icons.science_rounded,
                  title: 'Pipeline & AI Studio',
                ),
                const SizedBox(height: 24),

                _buildSectionHeader('HỆ THỐNG'),
                _buildNavItem(
                  index: 7,
                  icon: Icons.group_add_outlined,
                  activeIcon: Icons.group_add_rounded,
                  title: 'Quản Lý Người Dùng',
                ),
                _buildNavItem(
                  index: 6,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  title: 'Tài Khoản Cá Nhân',
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

  Widget _buildSectionHeader(String title) {
    if (isCollapsed) return const SizedBox(height: 6);
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.sidebarSectionText, // #8b9aa4
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'Manrope',
          letterSpacing: 0.6,
        ),
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
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.sidebarIconInactive),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Quay về trang chủ',
                        style: TextStyle(
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
            tooltip: isCollapsed ? 'Mở rộng thanh menu' : 'Thu gọn thanh menu',
            style: IconButton.styleFrom(
              hoverColor: AppColors.sidebarHover,
            ),
          ),
        ],
      ),
    );
  }
}
