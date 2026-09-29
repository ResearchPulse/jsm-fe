# Spec: Desktop Window Constraints & Responsive Minimum Dimensions

**Date:** 2026-09-26  
**Status:** Ready  
**Scope:** `jsm-fe` (Flutter Desktop & Web)

---

## Problem Statement
Khi chạy ứng dụng trên Windows Desktop, người dùng có thể tự do co hẹp cửa sổ xuống kích thước siêu nhỏ (< 400px), gây lỗi `RenderFlex overflow` và làm vỡ cấu trúc hiển thị bảng số liệu và biểu đồ học thuật. Hệ thống cần thiết lập kích thước tối thiểu cố định (`1024x700`) ở tầng OS cho Desktop, đồng thời hỗ trợ cơ chế phòng thủ cuộn ngang cho Web Laptop/PC để đảm bảo trải nghiệm giao diện luôn chuẩn mực, sắc nét.

---

## User Stories

<!-- P1 = MVP (must ship), P2 = nice-to-have, P3 = future/out-of-scope -->

- **[P1]** As a **Quản trị viên / Giảng viên chạy app trên Windows Desktop**, I want cửa sổ ứng dụng không thể bị kéo thu nhỏ dưới `1024x700` so that giao diện quản trị, biểu đồ đối chiếu phong cách và thanh công cụ luôn hiển thị đầy đủ, không bao giờ bị vỡ bố cục hay sọc vàng đen.  
  *Accepted when*: Kéo viền cửa sổ trên Windows chỉ có thể dừng ở mức tối thiểu 1024px chiều ngang và 700px chiều dọc; không thể kéo nhỏ hơn.

- **[P1]** As a **Người dùng mở ứng dụng lần đầu**, I want cửa sổ mở lên với kích thước chuẩn `1280x800` căn giữa màn hình so that tôi có thể bắt đầu làm việc ngay với không gian rộng rãi, thoáng đãng.  
  *Accepted when*: App khởi động tự động có kích thước 1280x800, vị trí ở giữa màn hình chính, title cửa sổ là "HyperData Lab - Journal System Miner".

- **[P2]** As a **Người dùng truy cập qua trình duyệt Web trên Laptop**, I want giao diện tự động bật thanh cuộn ngang nếu tab trình duyệt hẹp hơn 1024px so that tôi vẫn xem được toàn bộ nội dung mà không bị che khuất hoặc lỗi bố cục.  
  *Accepted when*: Mở app trên Web và thu nhỏ cửa sổ trình duyệt < 1024px, trang web giữ nguyên kích thước minWidth 1024px và cho phép cuộn ngang mượt mà.

- **[P3]** _(Out of scope - Tương lai)_: Chế độ Native Mobile View chuyên biệt cho màn hình smartphone iOS/Android.

---

## Functional Requirements

1. **FR-01: Cài đặt Dependency Native Window Manager**
   - Thêm `window_manager: ^0.4.3` vào `pubspec.yaml`.
   - Cấu hình Windows runner `windows/runner/main.cpp` nếu cần theo chuẩn Flutter desktop.

2. **FR-02: Cấu hình Khởi tạo Cửa sổ trong Bootstrap**
   - Trong `lib/bootstrap.dart` (hoặc `lib/main.dart`), bổ sung đoạn mã khởi tạo có kiểm tra `!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)`.
   - Thiết lập `minimumSize: const Size(1024, 700)`.
   - Thiết lập `size: const Size(1280, 800)`.
   - Thiết lập `center: true`.
   - Thiết lập `title: 'HyperData Lab - Journal System Miner'`.
   - Hiển thị cửa sổ qua `windowManager.waitUntilReadyToShow(..., () async { await windowManager.show(); await windowManager.focus(); })`.

3. **FR-03: Cơ chế Khung Bảo Vệ cho Web Platform**
   - Đối với môi trường Web (nơi `window_manager` không can thiệp được vào window trình duyệt), bọc Dashboard trong `LayoutBuilder` / `SingleChildScrollView` với `BoxConstraints(minWidth: 1024)` để đảm bảo không có bất kỳ RenderFlex overflow nào xảy ra nếu cửa sổ bị ép nhỏ.

---

## Non-Functional Requirements

- **Performance**: Thời gian khởi tạo window options thêm vào startup time không vượt quá 50ms.
- **Platform Safety**: 100% không văng lỗi Crash / MissingPluginException khi build và chạy trên Web (`dart:io` và `window_manager` được guard bằng `kIsWeb`).
- **Compatibility**: Tương thích Windows 10, Windows 11, macOS và các trình duyệt Chrome, Edge, Firefox, Safari.

---

## Success Criteria

- [ ] Khi chạy `flutter run -d windows`, người dùng không thể kéo viền cửa sổ hẹp hơn `1024px` chiều ngang hoặc thấp hơn `700px` chiều dọc.
- [ ] Cửa sổ ứng dụng mở lên lần đầu có kích thước `1280x800` và nằm giữa màn hình.
- [ ] Chạy `flutter analyze` đạt 0 compile errors và 0 warnings.
- [ ] Không có bất kỳ sọc vàng đen `RenderFlex overflow` nào xuất hiện trong toàn bộ quá trình sử dụng và thay đổi kích thước cửa sổ.

---

## Out of Scope

- Không phát triển giao diện responsive riêng biệt cho điện thoại di động thông minh (màn hình < 600px).
- Không khóa cứng cửa sổ ở dạng không cho phép phóng to (người dùng vẫn được Maximize và Fullscreen tự do).

---

## Assumptions

- Máy phát triển chạy hệ điều hành Windows có sẵn môi trường build C++ của Visual Studio (đã có sẵn do `flutter run -d window` đang chạy bình thường).
- Người dùng chỉ sử dụng ứng dụng trên Laptop, PC và màn hình rời chuyên dụng.
