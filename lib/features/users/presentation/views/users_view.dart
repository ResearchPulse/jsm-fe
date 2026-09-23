import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/create_account_usecase.dart';
import '../cubit/create_account_cubit.dart';
import '../pages/create_account_page.dart';

/// Admin sidebar view: entry point for account management.
class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'User Management',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create student and lecturer accounts.',
            style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontFamily: 'Manrope'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _ActionCard(
                icon: Icons.school_outlined,
                title: 'Create Student Account',
                subtitle: 'Register a new student user',
                onTap: () => _open(context, UserRole.student),
              ),
              const SizedBox(width: 16),
              _ActionCard(
                icon: Icons.co_present_outlined,
                title: 'Create Lecturer Account',
                subtitle: 'Register a new lecturer user',
                onTap: () => _open(context, UserRole.lecturer),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, UserRole role) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => CreateAccountCubit(
            createAccount: context.read<CreateAccountUseCase>(),
          ),
          child: CreateAccountPage(role: role),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.sidebarBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Manrope',
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                            fontFamily: 'Manrope')),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.sidebarIconInactive),
            ],
          ),
        ),
      ),
    );
  }
}
