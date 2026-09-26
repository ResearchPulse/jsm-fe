# Plan: Desktop Window Constraints & Responsive Minimum Dimensions

**Date:** 2026-09-26  
**Status:** In Progress  
**Risk:** tiny  
**Spec:** `plans/desktop-window-constraints/spec.md`  

---

## Architecture & Strategy

1. **Native Window Manager (`window_manager`)**:
   - Thêm package `window_manager: ^0.4.3` vào `pubspec.yaml`.
   - Trong `lib/bootstrap.dart`, sau khi `WidgetsFlutterBinding.ensureInitialized()`, thực hiện khởi tạo `window_manager` an toàn:
     - Guard bằng `if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux))`.
     - Cấu hình: `minimumSize = Size(1024, 700)`, `size = Size(1280, 800)`, `center = true`, `title = 'HyperData Lab - Journal System Miner'`.
     - Gọi `windowManager.waitUntilReadyToShow(...)` và hiển thị cửa sổ.

2. **Web Fallback / Layout Defense Gate**:
   - Trong `admin_dashboard_page.dart`, bọc Scaffold trong `LayoutBuilder`. Nếu `constraints.maxWidth < 1024`, bọc nội dung trong `SingleChildScrollView(scrollDirection: Axis.horizontal)` với `ConstrainedBox(constraints: BoxConstraints(minWidth: 1024))` để khi chạy trên Web hoặc khi viewport nhỏ hơn 1024px, giao diện giữ nguyên tỷ lệ chuẩn mà không bao giờ văng lỗi RenderFlex overflow.

---

## Phases

- [ ] **Phase 1**: Cài đặt dependency `window_manager` và cấu hình Desktop Native Window trong `bootstrap.dart`
- [ ] **Phase 2**: Thiết lập khung bảo vệ Web Fallback trong `admin_dashboard_page.dart`
- [ ] **Phase 3**: Kiểm tra biên dịch tĩnh (`flutter analyze`) và nghiệm thu
