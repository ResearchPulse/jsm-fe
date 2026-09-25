import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class AdminHeader extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onNewJobPressed;
  final ValueChanged<String>? onSearchChanged;

  const AdminHeader({
    super.key,
    required this.selectedIndex,
    required this.onNewJobPressed,
    this.onSearchChanged,
  });

  String _getTitle() {
    switch (selectedIndex) {
      case 0:
        return 'Bản Thảo Của Tôi';
      case 1:
        return 'Kho Bài Báo Khoa Học';
      case 2:
        return 'Cấu Hình Tạp Chí';
      case 3:
        return 'Hàng Đợi Thẩm Định';
      case 4:
        return 'Kho Lưu Trữ Snapshot';
      case 5:
        return 'Hồ Sơ Phong Cách';
      case 6:
        return 'Tài Khoản Cá Nhân';
      case 7:
        return 'Quản Lý Người Dùng';
      case 8:
        return 'Pipeline & AI Studio';
      default:
        return 'Không Gian Làm Việc';
    }
  }

  String _getBreadcrumb() {
    switch (selectedIndex) {
      case 0:
        return 'Giảng viên / Bản thảo';
      case 1:
        return 'Giảng viên / Kho bài báo';
      case 2:
        return 'Giảng viên / Cấu hình';
      case 3:
        return 'Thẩm định / Hàng đợi';
      case 4:
        return 'Thẩm định / Snapshots';
      case 5:
        return 'Thẩm định / Phong cách';
      case 6:
        return 'Hệ thống / Tài khoản';
      case 7:
        return 'Hệ thống / Người dùng';
      case 8:
        return 'R&D / Pipeline Member 2 & 3';
      default:
        return 'Hệ thống';
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _getBreadcrumb(),
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

          const Spacer(),

          // Search input
          SizedBox(
            width: 280,
            height: 44,
            child: TextField(
              onChanged: onSearchChanged,
              style: const TextStyle(fontSize: 14, fontFamily: 'Manrope'),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm không gian...',
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

          const SizedBox(width: 16),

          // Primary confident action button in #0071bc
          ElevatedButton.icon(
            onPressed: onNewJobPressed,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Tạo mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
