import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/language_switcher.dart';

class AdminHeader extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback? onNewJobPressed;
  final ValueChanged<String>? onSearchChanged;

  const AdminHeader({
    super.key,
    required this.selectedIndex,
    this.onNewJobPressed,
    this.onSearchChanged,
  });

  String _getTitle(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return context.l10n.titleJournalsMining;
      case 1:
        return context.l10n.titleNlpProfiles;
      case 2:
        return context.l10n.titleSystemDebug;
      default:
        return context.l10n.titleAdminDashboard;
    }
  }

  String _getBreadcrumb(BuildContext context) {
    switch (selectedIndex) {
      case 0:
        return context.l10n.breadcrumbResearch;
      case 1:
        return context.l10n.breadcrumbAcademic;
      case 2:
        return context.l10n.breadcrumbSystem;
      default:
        return context.l10n.breadcrumbAdmin;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.sidebarBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Breadcrumb & Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getBreadcrumb(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSubtle,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getTitle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),

          // Search input
          SizedBox(
            width: 280,
            height: 44,
            child: TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(fontSize: 14, fontFamily: 'Manrope'),
              decoration: InputDecoration(
                hintText: context.l10n.searchPlaceholder,
                hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSubtle, fontFamily: 'Manrope'),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSubtle),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                fillColor: AppColors.surfaceSoft,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Language Switcher on navbar right
          const LanguageSwitcher(),
        ],
      ),
    );
  }
}
