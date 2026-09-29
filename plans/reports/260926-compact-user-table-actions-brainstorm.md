# Brainstorm: Tinh gọn Bảng Quản lý Người dùng & Mini-Action Bar

**Date:** 2026-09-26  
**Slug:** `compact-user-table-actions`  
**Status:** Converged  

---

## 1. Context & Motivation

Sau khi bổ sung các chức năng CRUD cơ bản (chọn Role dropdown, chọn Trạng thái, nút Xóa và nút Xác nhận Lưu), giao diện bảng `UsersView` xuất hiện thêm cột riêng `THAO TÁC` với nút thùng rác màu đỏ chiếm nhiều diện tích ngang và tạo cảm giác bảng bị giãn, chưa đạt độ tinh gọn tối đa.

Người dùng yêu cầu:
> "- phải thêm 1 cột nữa à, gọn gàng nhất có thể"
> "- Gộp thông tin lại (ví dụ: đưa Ngày cấp xuống dòng phụ bên dưới Email/Tên để tiết kiệm 1 cột)"
> "- còn về nút xóa và xác nhận lưu vẫn cần design lại"

---

## 2. Ideas Explored

1. **Phương án vị trí gộp Ngày cấp:**
   - *Phương án 1A (Được chọn):* Đưa `Ngày cấp` xuống làm subtitle bên dưới Email (`huy.dq22@student.edu.vn` + `Tham gia: 25/09/2026`). Gom thông tin tài khoản và ngày khởi tạo về 1 cụm, tiết kiệm hẳn 1 cột riêng biệt.
   - *Phương án 1B (Bị loại):* Đưa `Ngày cấp` xuống dưới Họ và tên. (Làm cột Tên bị quá tải trong khi Email vẫn chiếm 1 cột trống).

2. **Phương án thiết kế lại Nút Xóa & Xác nhận Lưu:**
   - *Hướng A (Modal xác nhận tức thì trên Dropdown):* Bật popup xác nhận mỗi khi click dropdown, không có nút Lưu. (Bị loại vì gián đoạn thao tác khi muốn đổi nhanh nhiều dòng).
   - *Hướng B (Mini-Action Bar - Được chọn):*
     - Loại bỏ icon thùng rác màu đỏ chói mặc định. Thay bằng icon xám nhạt tinh tế (`textSubtle`), chỉ chuyển đỏ khi rê chuột (hover).
     - Thu gọn độ rộng cột Action từ 140px xuống ~72px vừa vặn.
     - Khi dòng có thay đổi (`isDirty`): Nút xóa tự động biến đổi thành cụm mini pill / icon `[✔ Lưu]` và `[✕ Hủy]` gọn gàng, tự biến mất khi lưu thành công.
   - *Hướng C (Auto-save + Undo Toast):* Tự động lưu không cần xác nhận. (Tiềm ẩn rủi ro thao tác nhầm trên tài khoản phân quyền cao).

---

## 3. User's Direction

- **Gộp thông tin:** Theo **1A** — Đưa `Ngày cấp` xuống dòng phụ bên dưới `Email tài khoản`. Xóa bỏ cột `NGÀY CẤP` riêng biệt để bảng thoáng mắt.
- **Thao tác:** Theo **Hướng B (Mini-Action Bar)**:
  - Cột thao tác thu nhỏ tối đa (~72px).
  - Trạng thái bình thường: Nút thùng rác xám tinh tế (chuyển đỏ khi hover).
  - Trạng thái dirty: Hiển thị cụm Mini Action Bar `[✔]` (Lưu) và `[✕]` (Hủy).
  - Xóa: Giữ nguyên hộp thoại cảnh báo xác nhận xóa vĩnh viễn và cơ chế chặn xóa Admin cuối cùng.

---

## 4. Open Questions & Risks

- **Độ co giãn khi màn hình hẹp:** Bảng giảm từ 6 cột xuống còn 5 cột (`HỌ VÀ TÊN`, `EMAIL & NGÀY CẤP`, `VAI TRÒ`, `TRẠNG THÁI`, `THAO TÁC`), giúp hiển thị hoàn hảo ngay cả trên màn hình nhỏ mà không bị cuộn ngang.
- **Rủi ro lockout admin:** Tiếp tục bảo lưu triệt để cơ chế lockout guard ở cả UI lẫn Backend.
