# Phase 02: Responsive Card Grid & Smooth Animations

## Canonical Phase ID: `phase-02-card-grid-widget-and-animations`
**Status:** complete  
**Priority:** P1  
**Covers stories:** US-01, US-02, US-03

## Mục tiêu
Tái thiết kế component thẻ tạp chí từ dạng thanh ngang sang dạng thẻ dọc (Vertical Card) cân đối, tích hợp hiệu ứng hover micro-interaction (nổi nhẹ + viền sáng), và xây dựng layout lưới responsive (3 cột desktop, 2 cột tablet, 1 cột mobile) kết hợp hiệu ứng xuất hiện thác đổ so le (staggered cascade) bằng `flutter_animate`.

## Nhiệm vụ cụ thể (Tasks)
1. Xây dựng widget thẻ tạp chí `JournalCard`:
   - Dạng thẻ dọc có bo góc tròn `BorderRadius.circular(16)` và viền tinh tế.
   - Header: Tên tạp chí tối đa 2 dòng (`maxLines: 2`, `overflow: TextOverflow.ellipsis`), kèm `Tooltip` hiển thị đầy đủ tên khi rê chuột. Góc phải là Status Badge gọn gàng (`Chưa phân tích` / `Đang phân tích` / `Đã phân tích`).
   - Body: 4 tag metadata (ISSN, Nhà xuất bản, Số bài báo, Trích dẫn) hiển thị dạng Wrap hoặc grid mini 2x2.
   - Footer: Divider mảnh, dòng chữ `OpenAlex ID: ...` và nút hành động `+ Cấu hình phân tích` (hoặc `Xem tiến trình`) luôn thẳng hàng ở đáy thẻ.
2. Tích hợp hiệu ứng Hover cho thẻ `JournalCard`:
   - Sử dụng `MouseRegion` với trạng thái `isHovered`.
   - `AnimatedContainer` chuyển động mượt trong 180ms:
     - Dịch chuyển nhẹ lên trên: `transform: Matrix4.translationValues(0, isHovered ? -4 : 0, 0)`
     - Đổ bóng mềm hơn: bóng mờ mở rộng khi hover
     - Đổi màu viền: viền chuyển sang màu `AppColors.primary` nhạt khi hover.
3. Xây dựng Lưới Responsive `JournalGrid`:
   - Sử dụng `LayoutBuilder` để đo kích thước chiều rộng khung hiển thị:
     - `width >= 1100`: 3 cột (`crossAxisCount = 3`)
     - `700 <= width < 1100`: 2 cột (`crossAxisCount = 2`)
     - `width < 700`: 1 cột (`crossAxisCount = 1`)
   - Thiết lập `childAspectRatio` phù hợp (~1.2 - 1.35) để các thẻ luôn có chiều cao đồng đều và không bị tràn viền (overflow).
4. Áp dụng Staggered Entrance Animation:
   - Sử dụng `.animate()` từ `flutter_animate` cho từng thẻ trong lưới:
     - `.fadeIn(duration: 350.ms, delay: (index * 40).ms, curve: Curves.easeOutCubic)`
     - `.slideY(begin: 0.08, end: 0, duration: 350.ms, delay: (index * 40).ms, curve: Curves.easeOutCubic)`
   - Đảm bảo animation chỉ chạy khi trang/danh sách được nạp mới.

## Files affected
- `lib/features/admin/presentation/views/journals_view.dart` (hoặc tạo thêm file widget con `lib/features/admin/presentation/widgets/journal_card.dart` nếu cần tách biệt để code gọn gàng)

## Dependencies
- Phụ thuộc vào `phase-01-dependencies-and-api-pagination` (cần thư viện `flutter_animate`).

## Tests & Acceptance Criteria
- Trên màn hình desktop rộng, danh sách tạp chí hiển thị đúng 3 cột dạng lưới.
- Co giãn cửa sổ trình duyệt: lưới tự động chuyển đổi giữa 3 cột -> 2 cột -> 1 cột mượt mà không có lỗi RenderFlex overflow.
- Khi tải danh sách, các thẻ lướt nhẹ từ dưới lên theo hiệu ứng so le (staggered delay ~40ms).
- Rê chuột vào từng thẻ: thẻ nhấc nhẹ lên 4px và đổi viền màu êm dịu trong 180ms.

## Risks & Notes
- Chiều cao các thẻ có thể bị lệch nếu nội dung metadata quá dài: Đảm bảo sử dụng layout ràng buộc cố định và cắt chữ hợp lý.
