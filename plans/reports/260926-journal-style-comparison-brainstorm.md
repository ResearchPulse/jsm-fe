# Brainstorm: So Sánh Hồ Sơ Phong Cách Giữa Các Tạp Chí (Journal Style Comparison)

**Date:** 2026-09-26  
**Status:** Decided  
**Target:** `jsm-fe` (Flutter Admin & Style Profiles View) & `jsm-be` (Existing Style Profiles API)

---

## 1. Ideas Explored

1. **Direction A: Ma trận thuộc tính (Attribute Grid Table)**:
   - Dạng bảng lớn hiển thị tất cả các tạp chí theo hàng, các cột là các chỉ số phong cách.
   - *Ưu điểm:* Dễ quét nhiều tạp chí cùng lúc.
   - *Hạn chế:* Quá tải thông tin, khó cảm nhận sự khác biệt đa chiều, không trực quan bằng biểu đồ.

2. **Direction B: Đối chiếu bản thảo người dùng với tạp chí (User Paper vs Journal)**:
   - Tải file bài viết của tác giả lên để chấm điểm tương đồng phong cách với 1 tạp chí mục tiêu.
   - *Ưu điểm:* Hướng tới tác giả nộp bài.
   - *Hạn chế:* Ngoài phạm vi hiện tại (cần thêm module phân tích bản thảo cá nhân).

3. **Direction C: So sánh đối chiếu trực diện 2–3 tạp chí (Side-by-side) kết hợp Radar Chart (Khuyên dùng & Đã chọn)**:
   - Cho phép chọn 2 hoặc 3 tạp chí đặt song song.
   - Trực quan hóa tương quan phong cách qua **Multi-series Radar Chart (Biểu đồ mạng nhện đa giác 6 trục)**.
   - Cung cấp thẻ / bảng so sánh Side-by-side chi tiết từng chỉ số (độ dài câu, tỷ lệ bị động, mật độ từ vựng, CARS moves, hedges vs boosters) và câu văn mẫu exemplar.

---

## 2. User's Direction

- **Chế độ so sánh:** Chọn 2–3 tạp chí đặt song song (Side-by-side) trên màn hình để đối chiếu từng chỉ số.
- **Trực quan hóa:** Sử dụng **Radar Chart** biểu diễn 6 trục phong cách (được vẽ mượt mà bằng `CustomPainter`, không phụ thuộc thư viện bên ngoài).
- **Mục tiêu:** So sánh phong cách học thuật giữa các tạp chí với nhau để nhà nghiên cứu nắm bắt khẩu vị xuất bản của từng journal.

---

## 3. Key Decisions & Architecture

1. **Vị trí tích hợp**:
   - Thêm nút Toggle chuyển chế độ trên header của `ProfilesReviewView`: `[ Xem chi tiết đơn lẻ ]` ⟷ `[ So sánh tạp chí (2-3) ]`.
   - Lưu trữ trạng thái danh sách tạp chí được chọn để so sánh `List<String> _selectedCompareIds` (tối thiểu 2, tối đa 3).

2. **6 Trục chuẩn hóa trên Radar Chart (Thang điểm 0–100%)**:
   - **Độ dài câu (Sentence Length)**: Scale từ mean_length (chuẩn hóa trên dải 15–35 từ).
   - **Mật độ từ vựng (Lexical Density)**: Tỷ lệ từ thực nghĩa (scale từ 0.30–0.70 sang 0–100%).
   - **Mức độ rào đón (Hedging)**: Tần suất từ khiêm tốn / rào đón per 1,000 words.
   - **Mức độ khẳng định (Boosters)**: Tần suất từ nhấn mạnh / khẳng định per 1,000 words.
   - **Tính trung lập lập luận (Neutral Stance)**: Tỷ lệ câu trung tính khách quan.
   - **Mô hình lập luận CARS (CARS Completeness)**: Điểm trung bình của 3 Move (Territory, Niche, Occupying).

3. **Giao diện so sánh Side-by-side**:
   - Mỗi tạp chí gán một màu định danh đồng bộ giữa Radar chart và Card chi tiết (Tạp chí 1: Xanh Primary, Tạp chí 2: Tím Iris, Tạp chí 3: Cam hổ phách).
   - Khối so sánh nhanh làm nổi bật các điểm khác biệt lớn nhất (Highlights).
   - Thẻ so sánh chi tiết các chỉ số thống kê (P10, P50, P90, Tỷ lệ bị động, Hedges, Boosters, Exemplar sentence).

---

## 4. Risks & Mitigations

- **Dữ liệu chưa có profile**: Nếu tạp chí chưa hoàn thành phân tích, hiển thị trạng thái badge `Chưa có hồ sơ` và gợi ý kích hoạt phân tích trước.
- **Hiệu năng vẽ biểu đồ**: Sử dụng `CustomPainter` tối ưu canvas và RepaintBoundary để animation và render siêu nhẹ 60fps trên Flutter Desktop / Web.
