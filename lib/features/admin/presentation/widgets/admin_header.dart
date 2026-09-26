import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/search_input_box.dart';

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
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
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
                    color: Color(0xFF64748B),
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
                    color: Color(0xFF0F172A),
                    fontFamily: 'Manrope',
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Sleek animated search input (ResearchPulse FE style)
          SearchInputBox(
            hintText: 'Tìm kiếm tạp chí, snapshot, jobs...',
            height: 38,
            expandOnFocus: true,
            width: 270,
            expandedWidth: 320,
            onChanged: onSearchChanged,
          ),
        ],
      ),
    );
  }
}
