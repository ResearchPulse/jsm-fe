# Brainstorm Report: Tinh Gọn Trải Nghiệm Giao Diện Người Dùng (Admin UI Simplification)

**Date:** 2026-09-26  
**Module:** `jsm-fe` (Flutter Admin Console)  
**Slug:** `admin-ui-simplification`

---

## 1. Bối cảnh & Yêu cầu của Người dùng

Sau khi hoàn thành đợt rút gọn Sidebar thành 3 tab cốt lõi, người dùng đã trải nghiệm giao diện thực tế và chỉ ra các điểm cần hoàn thiện để đạt độ tinh giản tối đa, tập trung vào góc nhìn của người dùng nghiên cứu (end-user mindset):
> *"User không quan tâm hệ thống ra sao đâu, đồng thời vì user không quan tâm hệ thống ra sao nên keep it simple lại nhé"*

Cụ thể có 5 yêu cầu trực tiếp:
1. **Phân trang cho cột bên trái**: Danh mục tạp chí cuộn quá dài (16 tạp chí), cần có phân trang nhỏ gọn, dễ duyệt.
2. **Cột bên phải – Xem đang phân tích tới bài nào**: Cần biết chính xác bài báo nào đang được xử lý theo thời gian thực (tên bài/mã bài) thay vì chỉ thấy tiến trình chung chung.
3. **Lỗi UI ở tab Hệ thống & Kỹ thuật**: Lược bỏ biểu đồ 6 bước kỹ thuật rườm rà (OpenAlex Crawl, GROBID TEI XML, Normalizer...) và các nút thừa, đưa về giao diện danh sách tác vụ sạch sẽ, đồng thời kiểm tra sự ổn định khi chuyển các sub-tab.
4. **Bỏ nút "Kích hoạt phân tích" ở Header**: Nút xanh trên thanh Header bị thừa vì người dùng đã có nút "Khai phá (300 bài)" 1-chạm to rõ ràng ngay trong thẻ Tạp chí.
5. **Đổi "Chu trình Khai phá & Chuẩn hóa (Pipeline)" thành "Đang phân tích"**: Thay thế toàn bộ 4 khối kỹ thuật (GROBID, MinIO, Normalizer, TEI XML) bằng một thẻ "Đang phân tích" siêu tinh gọn, thân thiện với người dùng thông thường.

---

## 2. Các phương án đã khám phá (Ideas Explored)

### A. Hiển thị "Đang phân tích" và bài báo đang xử lý ở Cột Phải
- **Phương án 1 (Đã chọn):** Thanh tiến độ mượt mà (VD: `299 / 300 bài - 99.6%`) kèm một dòng thông tin bài báo đang xử lý trực tiếp (VD: `Đang phân tích bài 245/300: "Deep Learning for Structural Bioinformatics..."`) với icon nhấp nháy hoặc spinner tinh tế.
- **Phương án 2:** Thanh tiến độ kèm accordion danh sách mini hiển thị 3–5 bài gần nhất đã xong.
  - *Đánh giá:* Quá tải thông tin, không đúng tiêu chí "keep it simple".
- **Phương án 3:** Chỉ hiện thanh phần trăm, không hiển thị tên bài.
  - *Đánh giá:* Không đáp ứng được yêu cầu của người dùng muốn biết đang phân tích tới bài nào.

### B. Phân trang Cột Trái (Danh mục Tạp chí)
- **Phương án 1 (Đã chọn):** Phân trang 5–6 tạp chí mỗi trang, chân trang đặt bộ điều khiển phân trang thanh lịch: `< Trang 1 / 3 >`, nút bấm nhạy, giữ nguyên từ khóa tìm kiếm và bộ lọc tags.
- **Phương án 2:** Cuộn vô tận (Infinite scrolling).
  - *Đánh giá:* Dễ gây mất vị trí và khó kiểm soát số lượng bài trên màn hình lớn.

### C. Xử lý Tab Hệ thống & Kỹ thuật
- **Phương án 1 (Đã chọn):** Lược bỏ khối tiến trình 6 bước cồng kềnh `TIẾN TRÌNH KHAI PHÁ DỮ LIỆU ĐANG VẬN HÀNH` và nút `Bắt đầu phân tích mới` trùng lặp trong `JobMonitorView`. Chỉ hiển thị thanh filter trạng thái và danh sách thẻ Job trực quan, gọn mắt. Đảm bảo chuyển đổi mượt mà giữa các sub-tab `Nhật Ký Tác Vụ & Debug`, `Cài Đặt Dịch Vụ`, `Quản Lý Người Dùng`.
- **Phương án 2:** Giữ nguyên biểu đồ nhưng thu nhỏ lại.
  - *Đánh giá:* Người dùng đã xác nhận không muốn nhìn thấy các chi tiết kỹ thuật backend rườm rà.

---

## 3. Quyết định của Người dùng (User's Direction)

- **Cột Trái:** Thêm phân trang (5-6 tạp chí/trang) với thanh điều khiển `< Trang X / Y >` ở cuối cột.
- **Cột Phải:**
  - Thay thế tiêu đề kỹ thuật bằng: **"Đang phân tích"** (hoặc **"Tiến độ phân tích"**).
  - Lược bỏ 4 ô kỹ thuật `GROBID / MinIO / Normalizer / TEI XML`.
  - Hiển thị thanh tiến độ phần trăm rõ ràng + 1 dòng mô tả tên bài báo đang bóc tách/phân tích theo thời gian thực (VD: `Đang phân tích bài 299/300: [Tên bài báo...]`).
- **Header:** Bỏ hoàn toàn nút `Kích hoạt phân tích` ở góc trên bên phải.
- **Tab Hệ thống & Kỹ thuật:** Lược bỏ biểu đồ 6 bước cồng kềnh, giữ lại danh sách tác vụ sạch sẽ, đảm bảo các sub-tab chuyển đổi trơn tru, không lỗi.

---

## 4. Rủi ro & Giải pháp (Risks & Mitigations)

1. **Dữ liệu tên bài báo đang xử lý**: API backend trả về danh sách job chung hay có thông tin bài hiện tại?
   - *Giải pháp:* Trong `JobMonitorView` và `JournalCommandCenterPanel`, khi job đang chạy, lấy tên bài báo gần nhất từ log/article status hoặc fallback thông minh: `Đang phân tích bài [current]/[total]: [Tiêu đề bài báo gần nhất...]` đảm bảo luôn hiển thị thông tin thực tế, sống động.
2. **State phân trang cột trái khi lọc tìm kiếm**: Khi người dùng gõ từ khóa tìm kiếm, nếu số trang giảm xuống thì có bị out of bounds không?
   - *Giải pháp:* Luôn reset `currentPage = 1` mỗi khi từ khóa tìm kiếm hoặc filter tag thay đổi.
