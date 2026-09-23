# Phase 01: Dependencies & API Pagination Integration

## Canonical Phase ID: `phase-01-dependencies-and-api-pagination`
**Status:** complete  
**Priority:** P1  
**Covers stories:** US-04

## Mục tiêu
Tích hợp thư viện `flutter_animate` vào dự án Flutter và nâng cấp tầng dữ liệu (`AdminRemoteDataSource`), `AdminState`, `AdminCubit` để hỗ trợ phân trang chuẩn xác từ backend (mặc định 10 tạp chí/trang).

## Nhiệm vụ cụ thể (Tasks)
1. Thêm `flutter_animate: ^4.5.2` vào `pubspec.yaml` (dưới mục `dependencies`).
2. Chạy lệnh `flutter pub get` để tải gói phụ thuộc và kiểm tra tương thích.
3. Tạo class model kết quả phân trang `OpenAlexPaginatedResult` (chứa `items: List<OpenAlexJournalModel>`, `totalCount: int`, `page: int`, `perPage: int`).
4. Cập nhật `AdminRemoteDataSource.searchOpenAlexJournals`:
   - Tham số: `search`, `page = 1`, `perPage = 10`.
   - Trả về `Future<OpenAlexPaginatedResult>`.
   - Bóc tách `total_count`, `page`, `per_page` từ `response.data['data']`.
5. Mở rộng `AdminState`:
   - Thêm các trường: `final int currentPage`, `final int totalCount`, `final int perPage`.
   - Cập nhật constructor, `copyWith`, và `props`.
6. Mở rộng `AdminCubit`:
   - Sửa `searchOpenAlex(String? query, {int page = 1})`: reset trang hoặc nhận số trang tùy chỉnh, cập nhật `totalCount`, `currentPage`, `perPage = 10` vào state.
   - Thêm hàm `changeOpenAlexPage(int page)`: kiểm tra guard (không gọi nếu đang search hoặc cùng trang hiện tại), sau đó kích hoạt tải trang mới.

## Files affected
- `pubspec.yaml`
- `lib/features/admin/data/datasources/admin_remote_datasource.dart`
- `lib/features/admin/presentation/cubit/admin_state.dart`
- `lib/features/admin/presentation/cubit/admin_cubit.dart`

## Dependencies
- Không có (Phase khởi tạo).

## Tests & Acceptance Criteria
- Lệnh `flutter pub get` chạy thành công không báo lỗi phiên bản.
- Gọi `searchOpenAlex('IEEE')` trả về đúng 10 phần tử và `totalCount > 10`, `currentPage == 1`, `perPage == 10`.
- Chạy `flutter analyze` hoặc test không bị lỗi type hay cú pháp.

## Risks & Notes
- Đảm bảo giá trị fallback cho `totalCount` khi backend trả về null (mặc định bằng `items.length`).
