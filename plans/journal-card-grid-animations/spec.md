# Spec: Journal Card Grid, Smooth Animations & Pagination
**Date:** 2026-09-23  
**Status:** Ready

## Problem Statement
Giao diện danh sách tạp chí khoa học hiện tại sử dụng dạng danh sách thẻ ngang đơn cột (`ListView`), gây lãng phí không gian hiển thị trên màn hình desktop, thiếu hiệu ứng thị giác (chuyển động đột ngột, không có phản hồi hover), và thiếu thanh phân trang (chỉ hiển thị cố định tối đa 20 kết quả) khiến người dùng khó duyệt khối lượng lớn dữ liệu bài báo.

## User Stories

### [P1] MVP
- **US-01 (Responsive 3-Column Card Grid)**: Là Quản trị viên/Người dùng nghiên cứu, tôi muốn danh sách tạp chí hiển thị dạng lưới 3 cột cân đối trên màn hình desktop (tự co về 2 cột trên tablet và 1 cột trên mobile), để tận dụng tối đa diện tích màn hình và dễ dàng so sánh các tạp chí.
  - *Accepted when*: Màn hình rộng >= 1100px hiển thị 3 cột; từ 700px - 1099px hiển thị 2 cột; < 700px hiển thị 1 cột. Các thẻ có chiều cao đồng đều và nút CTA luôn ghim ở đáy thẻ.
- **US-02 (Smooth Staggered Entrance Animation)**: Là người dùng, khi kết quả tìm kiếm hoặc dữ liệu tạp chí tải xong, tôi muốn các thẻ xuất hiện lướt nhẹ từ dưới lên theo hiệu ứng thác đổ so le (staggered fade & slide up) thay vì giật cục.
  - *Accepted when*: Các thẻ xuất hiện với hiệu ứng `FadeIn` kết hợp `SlideY(0.08 -> 0)` cách nhau 40-50ms bằng `flutter_animate`, tốc độ khung hình đạt 60fps mượt mà.
- **US-03 (Card Hover Micro-interactions)**: Là người dùng trên desktop/web, khi tôi di chuột qua từng thẻ tạp chí, thẻ cần có phản hồi thị giác nhấc nhẹ lên và viền sáng nhẹ.
  - *Accepted when*: Rê chuột vào thẻ kích hoạt chuyển đổi êm dịu (elevation tăng nhẹ, `translateY -4px`, viền đổi tông primary nhạt) trong khoảng 150-200ms.
- **US-04 (Server-side Pagination 10 items/page)**: Là người dùng, tôi muốn duyệt danh sách tạp chí theo trang (10 tạp chí / trang) với thanh điều hướng trang rõ ràng.
  - *Accepted when*: Thanh phân trang hiển thị bên dưới lưới gồm nút `Trước`, các số trang, nút `Sau`, kèm thông tin `Trang X / Y (Tổng Z tạp chí)`. Khi bấm đổi trang, query `page` và `per_page=10` được gửi xuống API backend và tải trang tương ứng.

### [P2] Nice-to-have
- **US-05 (Smooth Page & Shimmer Loading)**: Khi chuyển đổi giữa các trang hoặc đổi tab, hiển thị hiệu ứng skeleton loading mượt mà và animation chuyển cảnh êm dịu.
  - *Accepted when*: Lưới card hiển thị khung skeleton shimmer khi đang trong trạng thái loading phân trang.

### [P3] Out-of-scope
- Thay đổi cấu trúc cơ sở dữ liệu backend hoặc logic crawl của harvester.
- Xuất dữ liệu tạp chí ra file Excel/CSV.

## Functional Requirements
- **FR-01**: Tích hợp package `flutter_animate: ^4.5.0` vào `pubspec.yaml`.
- **FR-02**: Tái cấu trúc `_buildJournalCard` trong `journals_view.dart` từ layout hàng ngang (Row) sang dạng thẻ chữ nhật đứng (Vertical Card) phù hợp với lưới grid:
  - Header: Tiêu đề tạp chí (tối đa 2 dòng, có Tooltip nếu bị cắt) + Status badge (`Chưa phân tích` / `Đang phân tích` / `Đã phân tích`).
  - Body: 4 chip thông tin metadata (ISSN, Nhà xuất bản, Số bài báo, Số trích dẫn) bố trí gọn gàng.
  - Footer: Đường kẻ ngăn cách nhẹ, `OpenAlex ID` và nút hành động `+ Cấu hình phân tích` / `Xem tiến trình` ghim sát đáy.
- **FR-03**: Thay thế `ListView.separated` bằng `GridView.builder` hoặc `LayoutBuilder` với `SliverGridDelegateWithFixedCrossAxisCount` (3 cột desktop, 2 cột tablet, 1 cột mobile) có `childAspectRatio` tối ưu (~1.15 - 1.35).
- **FR-04**: Áp dụng hiệu ứng `.animate().fadeIn().slideY()` với độ trễ so le (stagger delay) 40ms/item cho từng card trong grid.
- **FR-05**: Bổ sung `MouseRegion` và `AnimatedContainer` cho thẻ card để tạo hiệu ứng hover nhấc nhẹ (`translateY -4px`).
- **FR-06**: Cập nhật `AdminRemoteDataSource.searchOpenAlexJournals` để trả về object chứa cả `items`, `total_count`, `page`, `per_page` thay vì chỉ `List<OpenAlexJournalModel>`.
- **FR-07**: Cập nhật `AdminState` và `AdminCubit` để lưu trạng thái `currentPage`, `totalCount`, `perPage = 10`, và phương thức `changeOpenAlexPage(int page)`.
- **FR-08**: Xây dựng widget điều hướng phân trang `_buildPaginationControl()` ở đáy trang với các nút Previous, Next, Page Numbers và thông số tổng.

## Non-Functional Requirements
- **NFR-01 (Frame Rate)**: Các chuyển động animation (entrance, hover, transition) phải đạt hiệu năng mượt mà 60fps trên trình duyệt web và desktop app, không gây giật lag hoặc tụt khung hình.
- **NFR-02 (Latency)**: Phản hồi hover của thẻ diễn ra trong khoảng 150ms – 200ms.
- **NFR-03 (Responsiveness)**: Tự động tính toán số cột grid tức thì khi người dùng co giãn kích thước cửa sổ trình duyệt.

## Success Criteria
- [ ] Thư viện `flutter_animate` được cài đặt và tích hợp thành công.
- [ ] Màn hình Quản lý Tạp chí hiển thị giao diện dạng Card Grid 3 cột trên desktop.
- [ ] Hiệu ứng staggered cascade animation hiển thị mượt mà khi load danh sách tạp chí.
- [ ] Hiệu ứng hover tương tác thẻ card hoạt động êm ái khi di chuột.
- [ ] Phân trang server-side hoạt động chính xác với 10 tạp chí mỗi trang, bấm chuyển trang cập nhật dữ liệu đúng.
- [ ] Code tuân thủ kiến trúc Flutter Bloc hiện tại, không phát sinh lỗi lint hoặc build.

## Out of Scope
- Sửa đổi backend API (vì API đã có sẵn pagination).
- Thay đổi logic nghiệp vụ của các module Harvester, Parser, Normalizer.

## Assumptions
- Backend `/admin/journals/openalex` đã hỗ trợ đầy đủ `page` và `per_page`, trả về trường `total_count`.
- Người dùng sử dụng trình duyệt web hoặc ứng dụng desktop hỗ trợ tốt animation đồ họa của Flutter Web/Desktop.
