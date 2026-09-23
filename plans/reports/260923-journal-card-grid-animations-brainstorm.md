# Brainstorm: Journal Card Grid, Smooth Animations & Pagination

**Date:** 2026-09-23

## Ideas Explored
- **Layout:**
  - 1-column wide horizontal card layout (hiện tại: chiếm trọn chiều ngang, chiếm nhiều khoảng trống khi xem trên màn hình lớn).
  - 2-column wide card grid (rộng rãi, nhưng số lượng thẻ hiển thị đồng thời ít hơn).
  - 3-column responsive card grid (tối ưu hóa diện tích hiển thị trên desktop, tự co giãn thành 2 cột trên tablet và 1 cột trên mobile).
- **Animation Framework:**
  - Native Flutter Animations (`AnimationController`, `TweenAnimationBuilder`, `AnimatedContainer`): Zero-dependency nhưng code boilerplate nhiều, khó kiểm soát staggered cascade.
  - `flutter_animate` library: Declarative, hỗ trợ mạnh mẽ hiệu ứng lướt so le (staggered cascade `FadeIn` + `SlideUp`), hover effects mượt mà 60fps.
- **Micro-interactions:**
  - Card hover elevation (`translateY -4px`, shadow dịu dàng, border highlight).
  - Page & tab transition mượt mà giữa danh sách tạp chí và tab cấu hình.
- **Pagination Strategy:**
  - Client-side pagination (cắt mảng 20 phần tử hiện có): Đơn giản nhưng không khai thác được toàn bộ dữ liệu backend.
  - Server-side pagination (truy vấn `page` và `per_page=10` xuống backend): Chuẩn RESTful, tận dụng trường `total_count` đã có trong `OpenAlexSearchResponse`.

## User's Direction
- Chọn layout **Grid 3 cột** cho giao diện danh sách tạp chí trên màn hình desktop.
- Áp dụng **trọn gói animation mượt mà (smooth)**: hiệu ứng xuất hiện so le khi load dữ liệu, hover interaction trên thẻ card và chuyển trang/tab.
- Thống nhất sử dụng thư viện **`flutter_animate`** để đạt độ mượt mà cao nhất và cú pháp code sạch sẽ.
- Bổ sung **phân trang (paging)** với kích thước **10 tạp chí / trang**.

## Open Questions
- Không còn câu hỏi bị chặn. Các quyết định cốt lõi đã được thống nhất hoàn toàn.

## Risks
- Chiều dài tên tạp chí (Journal Title) có thể chênh lệch lớn giữa các tạp chí (từ 1 dòng đến 4-5 dòng): Cần giới hạn `maxLines: 2`, `overflow: TextOverflow.ellipsis` và tooltip để card giữ được chiều cao cân đối.
- Tốc độ mạng khi lật trang liên tục: Cần skeleton loading / shimmer effect mượt mà khi đổi trang.
