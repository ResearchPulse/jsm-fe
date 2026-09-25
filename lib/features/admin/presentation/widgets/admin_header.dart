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
        return 'Tổng Quan Pipeline';
      case 1:
        return 'Danh Mục Tạp Chí';
      case 2:
        return 'Cấu Hình Khai Phá';
      case 3:
        return 'Giám Sát Tác Vụ';
      case 4:
        return 'Kho Corpus Snapshots';
      case 5:
        return 'Hồ Sơ Phong Cách';
      case 6:
        return 'Cài Đặt Hệ Thống';
      case 7:
        return 'Quản Lý Người Dùng';
      default:
        return 'Bảng Điều Khiển Quản Trị';
    }
  }

  String _getBreadcrumb() {
    switch (selectedIndex) {
      case 0:
        return 'Quản trị / Tổng quan';
      case 1:
        return 'Khai phá dữ liệu / Tạp chí khoa học';
      case 2:
        return 'Khai phá dữ liệu / Cấu hình';
      case 3:
        return 'Khai phá dữ liệu / Giám sát tác vụ';
      case 4:
        return 'Khai phá dữ liệu / Kho Snapshots';
      case 5:
        return 'Khai phá dữ liệu / Hồ sơ phong cách';
      case 6:
        return 'Hệ thống / Cài đặt';
      case 7:
        return 'Hệ thống / Người dùng';
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

          const SizedBox(width: 16),

          // Primary action button
          ElevatedButton.icon(
            onPressed: onNewJobPressed,
            icon: const Icon(Icons.bolt_rounded, size: 18),
            label: const Text('Kích hoạt phân tích'),
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
