import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/language_switcher.dart';

/// Displays the authenticated user's Central SSO profile information.
/// Requires an [AuthCubit] above it. Only SSO-supported fields are shown:
/// sub, email, name, picture.
class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.userInfoTitle),
        actions: const [
          LanguageSwitcher(),
          SizedBox(width: 12),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return Center(child: Text(context.l10n.notSignedIn));
          }
          final user = state.user;
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage: user.picture != null
                              ? NetworkImage(user.picture!)
                              : null,
                          child: user.picture == null
                              ? Text(_initials(user.name ?? user.email ?? '?'))
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            user.name ?? user.email ?? context.l10n.signedInUser,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _InfoRow(label: context.l10n.subjectLabel, value: user.sub),
                    _InfoRow(label: context.l10n.emailLabel, value: user.email ?? '—'),
                    _InfoRow(label: context.l10n.nameLabel, value: user.name ?? '—'),
                    _InfoRow(label: context.l10n.colRole, value: (user.role ?? 'USER').toUpperCase()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
          const Divider(),
        ],
      ),
    );
  }
}
