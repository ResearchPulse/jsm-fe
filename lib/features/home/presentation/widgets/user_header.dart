import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/language_switcher.dart';

class UserHeader extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback? onResetCheck;

  const UserHeader({
    super.key,
    required this.selectedIndex,
    this.onResetCheck,
  });

  String _getBreadcrumb() {
    switch (selectedIndex) {
      case 0:
        return 'Không gian Học thuật / Kiểm tra Bản thảo';
      case 1:
        return 'Không gian Học thuật / Gợi ý Tạp chí';
      case 2:
        return 'Không gian Học thuật / Lịch sử';
      default:
        return 'Không gian Học thuật';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.sidebarBorder, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            _getBreadcrumb(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSubtle,
              fontWeight: FontWeight.w500,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.sidebarActive,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Journal Dashboard',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                fontFamily: 'Manrope',
              ),
            ),
          ),
          const Spacer(),
          const LanguageSwitcher(),
        ],
      ),
    );
  }
}
