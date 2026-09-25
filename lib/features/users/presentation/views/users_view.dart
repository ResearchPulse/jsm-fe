import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../data/datasources/users_api_client.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/create_account_usecase.dart';
import '../cubit/create_account_cubit.dart';
import '../pages/create_account_page.dart';

/// Admin sidebar view: entry point for account management.
/// Connects to real Backend REST API to fetch and manage live user accounts.
class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  late final UsersApiClient _apiClient;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    final authRepo = context.read<AuthRepository?>();
    _apiClient = UsersApiClient(
      tokenProvider: () async => authRepo != null ? await authRepo.currentToken() : null,
    );
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _apiClient.getUsers();
      if (!mounted) return;
      setState(() {
        _users = list;
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

  void _open(BuildContext context, UserRole role) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => CreateAccountCubit(
            createAccount: context.read<CreateAccountUseCase>(),
          ),
          child: CreateAccountPage(role: role),
        ),
      ),
    );
    if (mounted) {
      _loadUsers();
    }
  }

  String _formatDate(dynamic dateVal) {
    if (dateVal == null) return 'N/A';
    try {
      final dt = DateTime.parse(dateVal.toString()).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dateVal.toString();
    }
  }

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFF7C3AED);
      case 'lecturer':
        return AppColors.primary;
      case 'student':
      default:
        return const Color(0xFF0D9488);
    }
  }

  String _roleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Quản trị viên (Admin)';
      case 'lecturer':
        return 'Giảng viên (Lecturer)';
      case 'student':
      default:
        return 'Sinh viên (Student)';
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Quản Lý Tài Khoản Người Dùng',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Manrope',
                      color: AppColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Cấp phát và quản lý quyền truy cập cho Giảng viên (khảo sát tạp chí) và Sinh viên (kiểm tra bản thảo).',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: _loadUsers,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Tải lại danh sách tài khoản',
                color: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Action Cards (Student & Lecturer Creation)
          Row(
            children: [
              _ActionCard(
                icon: Icons.school_outlined,
                title: 'Tạo tài khoản Sinh viên',
                subtitle: 'Cấp quyền truy cập module kiểm tra bản thảo bài báo (.docx / .pdf)',
                badgeText: 'Vai trò Student',
                onTap: () => _open(context, UserRole.student),
              ),
              const SizedBox(width: 20),
              _ActionCard(
                icon: Icons.co_present_outlined,
                title: 'Tạo tài khoản Giảng viên',
                subtitle: 'Cấp quyền xem hồ sơ phong cách, cấu hình tạp chí và xuất dữ liệu',
                badgeText: 'Vai trò Lecturer',
                onTap: () => _open(context, UserRole.lecturer),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // User Accounts Table
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text('HỌ VÀ TÊN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSubtle, fontFamily: 'Manrope')),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text('EMAIL TÀI KHOẢN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSubtle, fontFamily: 'Manrope')),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('VAI TRÒ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSubtle, fontFamily: 'Manrope')),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('NGÀY CẤP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSubtle, fontFamily: 'Manrope')),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('TRẠNG THÁI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSubtle, fontFamily: 'Manrope')),
                      ),
                    ],
                  ),
                ),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(48),
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
                            onPressed: _loadUsers,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_users.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'Chưa có tài khoản người dùng nào được tạo.',
                        style: TextStyle(color: AppColors.textMuted, fontFamily: 'Manrope'),
                      ),
                    ),
                  )
                else
                  for (int i = 0; i < _users.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              _users[i]['full_name'] ?? _users[i]['name'] ?? 'Chưa rõ',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Manrope'),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              _users[i]['email'] ?? '',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Manrope'),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _roleColor(_users[i]['role'] ?? '').withAlpha(24),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _roleLabel(_users[i]['role'] ?? ''),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _roleColor(_users[i]['role'] ?? ''),
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              _formatDate(_users[i]['created_at'] ?? _users[i]['createdAt']),
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Manrope'),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Icon(
                                  (_users[i]['is_active'] ?? true) ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                  size: 14,
                                  color: (_users[i]['is_active'] ?? true) ? AppColors.green700 : AppColors.error,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  (_users[i]['is_active'] ?? true) ? 'Hoạt động' : 'Tạm khóa',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: (_users[i]['is_active'] ?? true) ? AppColors.green700 : AppColors.error,
                                    fontFamily: 'Manrope',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < _users.length - 1)
                      const Divider(height: 1, color: AppColors.borderSoft),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badgeText;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
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
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.blue50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 22),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      badgeText,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Manrope',
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
              const SizedBox(height: 16),
              Row(
                children: const [
                  Text(
                    'Khởi tạo ngay',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
