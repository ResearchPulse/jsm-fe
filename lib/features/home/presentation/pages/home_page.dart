import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        AuthUser? user;
        if (state is AuthAuthenticated) {
          user = state.user;
        }

        final role = (user?.role ?? 'USER').toUpperCase();
        final isAdmin = role == 'ADMIN';

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Journal Dashboard',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Manrope',
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              // User Role Pill
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isAdmin ? const Color(0xFFF5F3FF) : const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isAdmin ? const Color(0xFFC4B5FD) : const Color(0xFF99F6E4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                      size: 14,
                      color: isAdmin ? const Color(0xFF7C3AED) : const Color(0xFF0D9488),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isAdmin ? 'ROLE: ADMIN' : 'ROLE: USER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Manrope',
                        color: isAdmin ? const Color(0xFF7C3AED) : const Color(0xFF0D9488),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Quick Switch Role for Testing
              IconButton(
                tooltip: isAdmin ? 'Chuyển nhanh sang USER test' : 'Chuyển nhanh sang ADMIN test',
                icon: Icon(
                  Icons.swap_horiz_rounded,
                  color: isAdmin ? const Color(0xFF0D9488) : const Color(0xFF7C3AED),
                ),
                onPressed: () {
                  if (isAdmin) {
                    context.read<AuthCubit>().mockLogin(
                          sub: 'mock-sso-user-id',
                          email: 'scholar.user@lab.edu.vn',
                          name: 'TS. Nguyễn Văn Scholar (User)',
                          role: 'USER',
                        );
                  } else {
                    context.read<AuthCubit>().mockLogin(
                          sub: 'mock-sso-admin-id',
                          email: 'admin@jsm.edu.vn',
                          name: 'Quản trị viên Hệ thống (Admin)',
                          role: 'ADMIN',
                        );
                  }
                },
              ),

              IconButton(
                tooltip: 'Sign out',
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => context.read<AuthCubit>().logout(),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // User greeting card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.ink900.withAlpha(4),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: isAdmin ? const Color(0xFFEDE9FE) : const Color(0xFFCCFBF1),
                            child: Icon(
                              isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                              size: 28,
                              color: isAdmin ? const Color(0xFF7C3AED) : const Color(0xFF0D9488),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      user?.name ?? 'Người dùng',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: 'Manrope',
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isAdmin ? const Color(0xFFEDE9FE) : const Color(0xFFCCFBF1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        role,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          fontFamily: 'Manrope',
                                          color: isAdmin ? const Color(0xFF7C3AED) : const Color(0xFF0D9488),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? 'Chưa rõ email',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Quick Test Switch Button
                          OutlinedButton.icon(
                            onPressed: () {
                              if (isAdmin) {
                                context.read<AuthCubit>().mockLogin(
                                      sub: 'mock-sso-user-id',
                                      email: 'scholar.user@lab.edu.vn',
                                      name: 'TS. Nguyễn Văn Scholar (User)',
                                      role: 'USER',
                                    );
                              } else {
                                context.read<AuthCubit>().mockLogin(
                                      sub: 'mock-sso-admin-id',
                                      email: 'admin@jsm.edu.vn',
                                      name: 'Quản trị viên Hệ thống (Admin)',
                                      role: 'ADMIN',
                                    );
                              }
                            },
                            icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                            label: Text(isAdmin ? 'Đổi sang USER' : 'Đổi sang ADMIN'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isAdmin ? const Color(0xFF0D9488) : const Color(0xFF7C3AED),
                              side: BorderSide(
                                color: isAdmin ? const Color(0xFF0D9488) : const Color(0xFF7C3AED),
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Module navigation buttons
                    Row(
                      children: [
                        Expanded(
                          child: _HomeModuleCard(
                            icon: Icons.admin_panel_settings_rounded,
                            title: 'Admin Dashboard',
                            subtitle: 'Quản lý tạp chí, jobs khai phá, user accounts & corpus.',
                            badge: 'ADMIN ONLY',
                            badgeColor: const Color(0xFF7C3AED),
                            badgeBg: const Color(0xFFEDE9FE),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const AdminDashboardPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _HomeModuleCard(
                            icon: Icons.spellcheck_rounded,
                            title: 'Manuscript Checker',
                            subtitle: 'Kiểm tra bản thảo bài báo khoa học so với phong cách tạp chí.',
                            badge: 'ALL ROLES',
                            badgeColor: const Color(0xFF0D9488),
                            badgeBg: const Color(0xFFCCFBF1),
                            onTap: () {
                              Navigator.of(context).pushNamed('/student-checker');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _HomeModuleCard(
                      icon: Icons.account_circle_outlined,
                      title: 'Thông Tin Người Dùng (SSO Profile)',
                      subtitle: 'Xem chi tiết thông tin tài khoản, subject id, token & phân quyền.',
                      badge: 'PROFILE',
                      badgeColor: AppColors.primary,
                      badgeBg: AppColors.blue50,
                      onTap: () {
                        Navigator.of(context).pushNamed('/user-info');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Color badgeBg;
  final VoidCallback onTap;

  const _HomeModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink900.withAlpha(3),
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: badgeColor, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Manrope',
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Manrope',
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                fontFamily: 'Manrope',
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}