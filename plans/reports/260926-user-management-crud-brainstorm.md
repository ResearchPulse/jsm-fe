# Brainstorm: Quản Lý Người Dùng & Thao Tác CRUD Trực Tiếp Trên Từng Dòng (User Management CRUD)

**Date:** 2026-09-26  
**Status:** Completed  
**Author:** Pair Programming Brainstorm Session  

---

## Ideas Explored

1. **Modal Popup chỉnh sửa chi tiết (Edit User Dialog):**
   - Click vào dòng người dùng hoặc nút "Sửa" để mở modal dialog chứa form đầy đủ (Họ tên, Email, Vai trò, Trạng thái hoạt động, Mật khẩu mới).
   - *Đánh giá:* Quen thuộc nhưng thao tác chậm, tốn nhiều click khi cần duyệt hoặc đổi trạng thái/vai trò hàng loạt người dùng.

2. **Menu 3 chấm thao tác phụ (More Actions Dropdown Menu):**
   - Đặt icon ba chấm `...` ở cuối mỗi dòng với các mục "Đổi vai trò", "Khóa/Mở khóa", "Xóa tài khoản".
   - *Đánh giá:* Ẩn các thao tác quan trọng vào menu con, người dùng không nhìn thấy ngay trạng thái hoặc mất thêm 1 click mở menu.

3. **Thao tác nhanh trực tiếp trên từng dòng (Inline Quick Actions) — ĐƯỢC CHỌN:**
   - Dropdown đổi vai trò (Sinh viên, Giảng viên, Quản trị viên) ngay tại cột VAI TRÒ.
   - Dropdown hoặc selector trạng thái (Hoạt động / Tạm khóa / Vô hiệu hóa) ngay tại cột TRẠNG THÁI.
   - Nút xác nhận lưu thay đổi (Check button / Nút Lưu) xuất hiện trên dòng khi có sự thay đổi giá trị để tránh bấm nhầm.
   - Nút Xóa (thùng rác đỏ) ở cột THAO TÁC kèm hộp thoại cảnh báo xác nhận xóa vĩnh viễn.
   - Ràng buộc an toàn: Không cho phép tự xóa/tự khóa tài khoản Admin đang đăng nhập hoặc tài khoản Admin cuối cùng của hệ thống.
   - *Đánh giá:* Tốc độ thao tác cực nhanh, trực quan, minh bạch và an toàn.

---

## User's Direction

- **Vị trí thao tác:** Trực tiếp ngay trên từng dòng dữ liệu trong bảng người dùng (`UsersView`), không chuyển trang, không phụ thuộc vào popup modal phụ.
- **Đổi vai trò (Role):** Click vào Dropdown trực tiếp trên dòng (chọn giữa *Sinh viên (Student)*, *Giảng viên (Lecturer)*, *Quản trị viên (Admin)*), có cơ chế xác nhận sau khi chọn.
- **Trạng thái hoạt động (Status):** Drop box chuyển trạng thái (*Hoạt động (Active)*, *Tạm khóa (Suspended)*, *Vô hiệu hóa (Inactive)*), có nút xác nhận sau khi có sự thay đổi.
- **Xóa tài khoản (Delete):** Nút thùng rác màu đỏ kèm Dialog xác nhận: *"Bạn có chắc muốn xóa vĩnh viễn tài khoản [Email]?"* trước khi thực thi lệnh xóa.
- **Ràng buộc bảo mật bắt buộc:** Hệ thống phải kiểm tra và chặn không cho phép xóa hoặc khóa tài khoản Admin đang đăng nhập hoặc tài khoản Admin duy nhất còn lại trong hệ thống.

---

## Open Questions

1. **Hiển thị nút xác nhận trên dòng:** Nút xác nhận (Icon Check/Save) sẽ hiển thị nổi bật ở cuối dòng ngay khi dòng đó rơi vào trạng thái "dirty" (có thay đổi Role hoặc Status) so với dữ liệu gốc từ API.
2. **Phần cứng hóa API Backend:** Cần bổ sung endpoint `PATCH /api/v1/users/{user_id}` trên FastAPI backend để nhận `{role?: string, is_active?: boolean, full_name?: string}` và xử lý kiểm tra an toàn cho Admin cuối cùng.

---

## Risks

1. **Mất quyền truy cập quản trị hệ thống (Lockout Risk):**
   - *Nguy cơ:* Nếu Admin tự hạ quyền của mình xuống Student hoặc tự khóa tài khoản, toàn bộ quyền cấu hình và quản trị hệ thống sẽ bị mất.
   - *Giải pháp:* Backend chặn ở cấp Service/Database: đếm số lượng Admin đang active trước khi cho phép thay đổi `role != 'admin'` hoặc `is_active == false` hoặc `delete`.
2. **Xung đột phiên làm việc:**
   - *Nguy cơ:* Người dùng bị khóa tài khoản vẫn giữ JWT token cũ và tiếp tục gọi API.
   - *Giải pháp:* Backend xác thực kiểm tra cờ `is_active` của User trong DB hoặc Redis cache ở mỗi request xác thực token.
