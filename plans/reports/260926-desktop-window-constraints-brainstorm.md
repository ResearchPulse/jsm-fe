# Brainstorm: Giới Hạn Kích Thước Tối Thiểu Cửa Sổ Desktop & Responsive Cho Admin Dashboard

**Date:** 2026-09-26  
**Status:** Completed  
**Author:** Pair-Programming (Antigravity & User)

---

## 1. Challenge & Context
Trong quá trình chạy và thử nghiệm ứng dụng `jsm-fe` trên nền tảng Desktop (Windows), người dùng có thể tự do kéo co hẹp cửa sổ hệ điều hành xuống kích thước siêu nhỏ (~300px – 350px, tương đương màn hình smartphone dạng đứng). 

Do bản chất của hệ thống là **Admin & NLP Mining Dashboard** (nhiều bảng dữ liệu 5–6 cột, biểu đồ Radar đối chiếu đa chiều, panel điều khiển Pipeline thu thập & bóc tách Grobid, thanh giám sát Celery 6 giai đoạn), việc ép giao diện hiển thị ở chiều rộng 300px gây ra hiện tượng sọc vàng đen `RenderFlex overflow` và làm vỡ cấu trúc bố cục nghiên cứu học thuật.

Câu hỏi cốt lõi được đặt ra: **"Có nên khóa chỉ cho phép kích thước/responsive trong một giới hạn nhất định hay không?"**

---

## 2. Ideas Explored
1. **Hướng A: Khóa cứng kích thước tối thiểu cửa sổ Desktop (`window_manager.setMinimumSize`)**
   - Đặt `minSize = Size(1024, 700)` ở tầng Native Window của hệ điều hành Windows/macOS/Linux.
   - Ngăn người dùng kéo viền cửa sổ nhỏ hơn giới hạn chuẩn laptop.
   - Đây là pattern chuẩn công nghiệp của các app Desktop quản trị/công cụ chuyên sâu (VS Code, Tableau, Figma, Slack Desktop).
   - *Đánh giá*: Thực dụng, bảo vệ 100% tính toàn vẹn và thẩm mỹ của dashboard mà không tốn công viết layout phụ cho smartphone.

2. **Hướng B: Giới hạn kích thước linh hoạt với thanh cuộn ngang toàn trang (Layout Gate)**
   - Ràng buộc `BoxConstraints(minWidth: 1024)` bọc trong `SingleChildScrollView(scrollDirection: Axis.horizontal)`.
   - Nếu viewport nhỏ hơn 1024px, giao diện giữ nguyên tỷ lệ chuẩn và cho phép cuộn ngang thay vì co ép nội dung.
   - *Đánh giá*: Hoạt động hoàn hảo trên môi trường Web Browser (nơi không có quyền can thiệp vào cửa sổ trình duyệt).

3. **Hướng C: Full Adaptive Mobile (Co giãn linh hoạt xuống 320px – 400px)**
   - Tái thiết kế toàn bộ phân hệ quản trị với NavigationBar ở đáy, chuyển bảng thành thẻ cuộn dọc, thu gọn biểu đồ.
   - *Đánh giá*: Tốn công sức lớn (như phát triển thêm 1 app mobile riêng biệt), trong khi tập người dùng (Giảng viên, Nhà nghiên cứu, Quản trị viên phòng lab) thực tế 100% làm việc trên Laptop/PC.

---

## 3. User's Direction
Người dùng đã chốt dứt khoát định hướng:
- **Nền tảng mục tiêu chính**: Desktop Windows (và Web Laptop/PC).
- **Lựa chọn A (Thực dụng & Chuẩn Desktop)**:
  - Khóa kích thước tối thiểu: `minimumSize = Size(1024, 700)`.
  - Kích thước mở mặc định (`defaultSize`): `Size(1280, 800)`, tự động căn giữa màn hình (`center: true`).
  - Cho phép người dùng phóng to (Maximize / Fullscreen) tùy ý.
  - Áp dụng cơ chế phòng thủ kép: Trên Desktop dùng `window_manager` chặn kéo viền ở tầng OS; trên Web dùng `BoxConstraints(minWidth: 1024)` + thanh cuộn ngang để không bao giờ vỡ giao diện.

---

## 4. Key Decisions & Architecture
1. **Dependency**: Thêm package `window_manager: ^0.4.3` vào `pubspec.yaml` (dành cho Windows/macOS/Linux).
2. **Bootstrap Entrypoint**: Khởi tạo `windowManager.ensureInitialized()` trong `lib/bootstrap.dart` hoặc `lib/main.dart` có kiểm tra điều kiện nền tảng `!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)`.
3. **Web Compatibility**: Giữ nguyên tính độc lập của Web (không gọi Native window API trên Web), bọc Root view bằng khung cuộn ngang tối thiểu 1024px.
4. **Window Options**:
   - `size`: 1280 x 800
   - `minimumSize`: 1024 x 700
   - `center`: true
   - `title`: "HyperData Lab - Journal System Miner"

---

## 5. Risks & Mitigation
- **Risk 1**: `window_manager` có thể yêu cầu biên dịch C++ native runner trên Windows (thường tự động nhận diện nếu đã cài Visual Studio C++ build tools).
  - *Mitigation*: Cấu hình chuẩn `windows/runner/main.cpp` theo tài liệu chính thức của package, đảm bảo fallback an toàn nếu chưa build native.
- **Risk 2**: Xung đột khi chạy trên Web platform (do `dart:io` không khả dụng trên Web).
  - *Mitigation*: Sử dụng conditional imports hoặc `kIsWeb` từ `package:flutter/foundation.dart` trước khi import hoặc gọi các API của `window_manager`.
