# Phase 03: Pagination Controls & View Integration

## Canonical Phase ID: `phase-03-pagination-controls-and-integration`
**Status:** complete  
**Priority:** P1  
**Covers stories:** US-04, US-05

## Mục tiêu
Thiết kế widget thanh phân trang `PaginationBar` ở cuối danh sách kết quả, kết nối với `AdminCubit.changeOpenAlexPage()`, xử lý trạng thái đang tải (skeleton shimmer/loading feedback), và tích hợp toàn diện vào `JournalsView`.

## Nhiệm vụ cụ thể (Tasks)
1. Xây dựng widget điều hướng phân trang `_buildPaginationControls()`:
   - Nút `« Trang trước` (Disabled khi `currentPage == 1` hoặc `isSearching`).
   - Các nút số trang thông minh (ví dụ: `1`, `2`, `3`, ..., `N`).
   - Nút `Trang sau »` (Disabled khi `currentPage >= totalPages` hoặc `isSearching`).
   - Thống kê tóm tắt: `Hiển thị X - Y trên tổng số Z tạp chí (Trang A/B)`.
   - Nút bấm có hiệu ứng hover mượt mà và hiển thị nổi bật số trang đang chọn (active indicator).
2. Xử lý sự kiện chuyển trang:
   - Khi bấm vào số trang hoặc nút Prev/Next: gọi `context.read<AdminCubit>().changeOpenAlexPage(targetPage)`.
   - Tự động cuộn nhẹ (Smooth Scroll) lên đầu danh sách tạp chí để người dùng không phải cuộn chuột thủ công.
3. Hoàn thiện trạng thái Loading (Skeleton / Shimmer / Transition):
   - Khi `state.isSearching == true` (trong lúc đổi trang hoặc tìm kiếm mới): hiển thị lưới skeleton placeholder gồm 6–10 ô thẻ mờ với hiệu ứng shimmer hoặc xung nhịp nhẹ (`.animate(onPlay: (controller) => controller.repeat()).shimmer()`).
   - Không làm biến mất đột ngột hay gây giật layout khi đang tải.
4. Tích hợp Header thông tin:
   - Cập nhật dòng chữ thống kê ở đầu danh sách: "Tìm thấy ${state.totalCount} tạp chí phù hợp (Đang hiển thị 10 tạp chí mỗi trang)".
5. Kiểm tra toàn diện luồng tìm kiếm và chuyển trang:
   - Tìm kiếm từ khóa mới -> reset về Trang 1.
   - Bấm các quick chip (IEEE, Elsevier, Nature...) -> reset về Trang 1 và tải 10 kết quả đầu.
   - Bấm phân trang -> giữ nguyên từ khóa tìm kiếm và tải trang tương ứng.

## Files affected
- `lib/features/admin/presentation/views/journals_view.dart`

## Dependencies
- Phụ thuộc vào `phase-01-dependencies-and-api-pagination` và `phase-02-card-grid-widget-and-animations`.

## Tests & Acceptance Criteria
- Thanh phân trang hiển thị đầy đủ ở đáy danh sách khi có dữ liệu.
- Bấm trang 2, 3: dữ liệu 10 tạp chí mới được tải từ backend, số trang active chuyển sang số tương ứng.
- Khi ở trang 1: nút Prev bị vô hiệu hóa.
- Khi đang tải: các nút bấm bị khóa tạm thời để tránh spam request, xuất hiện shimmer loading mượt mà.
- Tìm kiếm từ khóa mới: trang được tự động đưa về trang 1.

## Risks & Notes
- Khi tổng số tạp chí là 0: ẩn thanh phân trang hoặc hiển thị thông báo "Không tìm thấy tạp chí nào".
