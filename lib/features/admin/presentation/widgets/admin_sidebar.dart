import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

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
          _buildBrandHeader(context),
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
                  title: 'Trung tâm Tạp chí',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  index: 1,
                  icon: Icons.psychology_outlined,
                  activeIcon: Icons.psychology_rounded,
                  title: 'Hồ sơ & Đối chuẩn NLP',
                ),
                const SizedBox(height: 6),
                _buildNavItem(
                  index: 2,
                  icon: Icons.tune_outlined,
                  activeIcon: Icons.tune_rounded,
                  title: 'Hệ thống & Kỹ thuật',
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.sidebarBorder, height: 1),
          _buildAccountProfile(context),
        ],
      ),
    );
  }

  Widget _buildBrandHeader(BuildContext context) {
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 14 : 18),
      alignment: Alignment.centerLeft,
      child: isCollapsed
          ? Center(
              child: Tooltip(
                message: 'Mở rộng thanh menu',
                child: InkWell(
                  onTap: onToggleCollapse,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0071BC), Color(0xFF2596BE)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0071BC).withOpacity(0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'H',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Row(
              children: [
                // Logo "H"
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0071BC), Color(0xFF2596BE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0071BC).withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'H',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'HyperData Lab',
                    style: TextStyle(
                      color: Color(0xFF122331),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Manrope',
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Nút thu nhỏ navbar đẩy lên đây
                IconButton(
                  onPressed: onToggleCollapse,
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.sidebarIconInactive,
                    size: 22,
                  ),
                  tooltip: 'Thu gọn thanh menu',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  style: IconButton.styleFrom(
                    hoverColor: AppColors.sidebarHover,
                  ),
                ),
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
        color: isSelected ? AppColors.sidebarActive : Colors.transparent,
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
                    ? AppColors.sidebarActiveIcon
                    : AppColors.sidebarIconInactive,
                size: 21,
              ),
              if (!isCollapsed) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.sidebarActiveText
                          : AppColors.sidebarTextInactive,
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

  String _getInitials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'A';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  Widget _buildAccountProfile(BuildContext context) {
    AuthUser? user;
    try {
      final state = context.watch<AuthCubit>().state;
      if (state is AuthAuthenticated) {
        user = state.user;
      }
    } catch (_) {
      // Fallback if not inside AuthCubit context
    }

    final displayName = (user?.name != null && user!.name!.trim().isNotEmpty)
        ? user.name!
        : (user?.email?.split('@').first ?? 'Admin');
    final email = user?.email ?? 'admin@hcmus.edu.vn';
    final role = (user?.role ?? 'ADMIN').toUpperCase();
    final initials = _getInitials(displayName);

    if (isCollapsed) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        child: PopupMenuButton<String>(
          tooltip: '$displayName ($role)',
          offset: const Offset(56, -10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (val) => _handleProfileMenuAction(context, val),
          itemBuilder: (context) => [
            PopupMenuItem(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 10),
                  Text('Hồ sơ tài khoản', style: TextStyle(fontSize: 13, fontFamily: 'Manrope')),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'home',
              child: Row(
                children: [
                  Icon(Icons.home_outlined, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 10),
                  Text('Trang chủ người dùng', style: TextStyle(fontSize: 13, fontFamily: 'Manrope')),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text(
                    'Đăng xuất',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
            ),
          ],
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF0071BC),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.sidebarBorder),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 17,
              backgroundColor: const Color(0xFF0071BC),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: 'Manrope',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7C3AED),
                            fontFamily: 'Manrope',
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSubtle,
                            fontFamily: 'Manrope',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // More / Menu action
            PopupMenuButton<String>(
              tooltip: 'Tùy chọn tài khoản',
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              icon: const Icon(
                Icons.unfold_more_rounded,
                size: 18,
                color: AppColors.sidebarIconInactive,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onSelected: (val) => _handleProfileMenuAction(context, val),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline_rounded, size: 18, color: AppColors.textSecondary),
                      SizedBox(width: 10),
                      Text('Hồ sơ tài khoản', style: TextStyle(fontSize: 13, fontFamily: 'Manrope')),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'home',
                  child: Row(
                    children: [
                      Icon(Icons.home_outlined, size: 18, color: AppColors.textSecondary),
                      SizedBox(width: 10),
                      Text('Trang chủ người dùng', style: TextStyle(fontSize: 13, fontFamily: 'Manrope')),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text(
                        'Đăng xuất',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleProfileMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'info':
        Navigator.of(context).pushNamed('/user-info');
        break;
      case 'home':
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 'logout':
        try {
          context.read<AuthCubit>().logout();
        } catch (_) {}
        break;
    }
  }
}
