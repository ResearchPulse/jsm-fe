import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

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

  String _getTitle() {
    switch (selectedIndex) {
      case 0:
        return 'Trung Tâm Tạp Chí & Khai Phá';
      case 1:
        return 'Hồ Sơ & Đối Chuẩn NLP';
      case 2:
        return 'Hệ Thống & Kỹ Thuật';
      default:
        return 'Bảng Điều Khiển Quản Trị';
    }
  }

  String _getBreadcrumb() {
    switch (selectedIndex) {
      case 0:
        return 'Nghiên cứu / Khai phá & Pipeline';
      case 1:
        return 'Học thuật / Hồ sơ phong cách & Corpus';
      case 2:
        return 'Hệ thống / Giám sát & Cài đặt';
      default:
        return 'Quản trị';
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
                  _getBreadcrumb(),
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
                  _getTitle(),
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
          const SizedBox(width: 16),

          // Search input
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280, minWidth: 160),
            child: SizedBox(
              height: 44,
              child: TextField(
                onChanged: onSearchChanged,
                style: const TextStyle(fontSize: 14, fontFamily: 'Manrope'),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tạp chí, snapshot, jobs...',
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
          ),
        ],
      ),
    );
  }
}
