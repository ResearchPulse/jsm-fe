import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _autoPurge = true;
  double _retentionDays = 30.0;
  bool _politePool = true;
  double _requestsPerSecond = 10.0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Cài Đặt Hệ Thống & Tham Số Vận Hành',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Manrope',
              color: AppColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Quản trị bảo mật dữ liệu bản thảo, quy tắc lưu trữ tạm thời và giới hạn tốc độ cào bài học thuật.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              fontFamily: 'Manrope',
            ),
          ),
          const SizedBox(height: 24),

          // SSO Authentication Panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 20, color: AppColors.primary),
                    SizedBox(width: 10),
                    Text(
                      'Xác Thực Tập Trung Phòng Thí Nghiệm (Central SSO)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Manrope'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSoft),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.green50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.green100),
                        ),
                        child: const Icon(Icons.check_rounded, color: AppColors.green700, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đang kết nối phiên OIDC SSO',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Manrope'),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Nhà cung cấp danh tính phòng lab (Keycloak OIDC) • Client ID: researchpulse-ecosystem',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Manrope'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.green50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'HOẠT ĐỘNG',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.green700, fontFamily: 'Manrope'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Privacy & Retention Panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.privacy_tip_outlined, size: 20, color: AppColors.primary),
                    SizedBox(width: 10),
                    Text(
                      'Bảo Mật Bản Thảo & Chính Sách Lưu Trữ',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Manrope'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Bản thảo của tác giả chỉ là các bản nháp tạm thời phục vụ chấm điểm và không bao giờ bị gộp vào kho Corpus vĩnh viễn.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontFamily: 'Manrope'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Tự động dọn dẹp file nháp tạm thời',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Manrope'),
                  ),
                  subtitle: Text(
                    'Tự động xóa sạch file bản thảo PDF/DOCX sau ${_retentionDays.toInt()} ngày (tối đa 30 ngày)',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Manrope'),
                  ),
                  value: _autoPurge,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _autoPurge = val),
                ),
                Slider(
                  value: _retentionDays,
                  min: 1,
                  max: 30,
                  divisions: 29,
                  activeColor: AppColors.primary,
                  onChanged: _autoPurge ? (val) => setState(() => _retentionDays = val) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Polite Crawler Panel
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.speed_rounded, size: 20, color: AppColors.primary),
                    SizedBox(width: 10),
                    Text(
                      'Cơ Chế Cào Bài Lịch Sự (Polite Pool)',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Manrope'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gắn email của phòng lab vào HTTP header khi gửi request đến OpenAlex / CrossRef để tránh lỗi chặn IP (HTTP 429).',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted, fontFamily: 'Manrope'),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Kích hoạt Polite Pool cho OpenAlex',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Manrope'),
                  ),
                  subtitle: Text(
                    'Giới hạn tối đa ${_requestsPerSecond.toInt()} requests / giây',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Manrope'),
                  ),
                  value: _politePool,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) => setState(() => _politePool = val),
                ),
                Slider(
                  value: _requestsPerSecond,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  activeColor: AppColors.primary,
                  onChanged: _politePool ? (val) => setState(() => _requestsPerSecond = val) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã lưu các thiết lập hệ thống thành công.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.save_rounded, size: 18),
            label: const Text('Lưu toàn bộ cài đặt'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
