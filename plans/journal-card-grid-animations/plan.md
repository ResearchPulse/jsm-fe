# Plan: Journal Card Grid, Smooth Animations & Pagination

Mode: auto
Risk: normal — multi-file Flutter UI & state changes, no auth/schema risk

## Architecture & Design Overview
Dự án sẽ nâng cấp giao diện Quản lý Tạp chí (`journals_view.dart`) từ bố cục danh sách thẻ ngang đơn cột (1-column list) sang **Lưới thẻ 3 cột responsive (3-column Card Grid)**, tích hợp thư viện **`flutter_animate`** để mang lại chuyển động mượt mà (staggered cascade entrance và hover micro-interactions), đồng thời kết nối phân trang server-side **10 tạp chí / trang** thông qua `AdminCubit` và `AdminRemoteDataSource`.

```
[ User Input / Tab Mount ]
         │
         ▼
[ AdminCubit.searchOpenAlex(query, page, perPage=10) ]
         │
         ▼
[ AdminRemoteDataSource.searchOpenAlexJournals ] ──(HTTP GET /admin/journals/openalex)──> [ FastAPI Backend ]
         │                                                                                  │ (items, total_count, page, per_page)
         ▼                                                                                  │
[ AdminState (openAlexJournals, totalCount, currentPage, perPage) ] <───────────────────────┘
         │
         ▼
[ JournalsView LayoutBuilder (Desktop: 3 cols / Tablet: 2 cols / Mobile: 1 col) ]
         │
         ├──> [ Staggered FadeIn + SlideY Entrance Animation (.animate().fadeIn().slideY()) ]
         │
         ├──> [ JournalCard Widget with AnimatedContainer Hover (translateY -4px, shadow, glow) ]
         │
         └──> [ PaginationBar Widget (Prev, Page 1..N, Next, Total Count Display) ]
```

## User Stories & Priority Mapping
- **US-01 [P1] (Responsive 3-Column Card Grid)**: Covered in Phase 2
- **US-02 [P1] (Smooth Staggered Entrance Animation)**: Covered in Phase 2
- **US-03 [P1] (Card Hover Micro-interactions)**: Covered in Phase 2
- **US-04 [P1] (Server-side Pagination 10 items/page)**: Covered in Phase 1 & Phase 3
- **US-05 [P2] (Smooth Page & Shimmer Loading)**: Covered in Phase 3

## Phase Structure
1. `phase-01-dependencies-and-api-pagination.md` — Tích hợp `flutter_animate` và nâng cấp Data Source / Cubit / State hỗ trợ phân trang server-side.
2. `phase-02-card-grid-widget-and-animations.md` — Thiết kế thẻ dọc (Vertical Card), hiệu ứng hover và lưới 3 cột responsive kèm staggered cascade animation.
3. `phase-03-pagination-controls-and-integration.md` — Xây dựng thanh điều hướng phân trang, tích hợp trạng thái tải mượt mà và hoàn thiện giao diện `journals_view.dart`.

## Phase Progress
- [x] Phase 1: `phase-01-dependencies-and-api-pagination.md`
- [x] Phase 2: `phase-02-card-grid-widget-and-animations.md`
- [x] Phase 3: `phase-03-pagination-controls-and-integration.md`

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-09-23 16:54
**Phase in progress:** (all completed)
**Status:** All 3 phases completed successfully. 100% tests passing, 0 analyzer issues.

### Decisions made this session
- Tích hợp thành công `flutter_animate: ^4.5.2` vào `pubspec.yaml`.
- Thêm model `OpenAlexPaginatedResult` và cập nhật `AdminRemoteDataSource` để trích xuất `total_count`, `page`, `per_page` với mặc định `perPage = 10`.
- Mở rộng `AdminState` và `AdminCubit` hỗ trợ `currentPage`, `totalCount`, `perPage` và phương thức `changeOpenAlexPage`.
- Tái cấu trúc layout danh sách tạp chí từ 1 cột sang **Lưới 3 cột responsive** (1050px+ 3 cột, 680px-1050px 2 cột, <680px 1 cột).
- Thiết kế thẻ `_JournalCardWidget` đồng đều chiều cao, kèm hiệu ứng hover mượt mà (dịch chuyển `translateY -4px`, đổ bóng mềm, viền sáng nhẹ trong 180ms).
- Tích hợp hiệu ứng xuất hiện dạng thác đổ so le (staggered cascade `.animate().fadeIn().slideY()`) với độ trễ 40ms mỗi thẻ.
- Bổ sung hiệu ứng skeleton shimmer loading grid khi đang tìm kiếm hoặc chuyển trang.
- Xây dựng thanh điều hướng phân trang `_buildPaginationBar` (Prev, Next, Page Numbers, thống kê tổng) kết nối mượt mà với cuộn nhẹ lên đầu trang.
- Bổ sung bộ kiểm thử `test/admin_pagination_test.dart` đạt 100% pass.

### Next immediate action
Bàn giao hoàn tất cho người dùng.


