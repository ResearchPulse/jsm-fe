# Spec: Tinh gọn Bảng Quản lý Người dùng & Mini-Action Bar

**Date:** 2026-09-26  
**Status:** Ready for Planning  
**Target Module:** `jsm-fe` (`UsersView`)

---

## 1. Problem Statement

Sau khi bổ sung các chức năng CRUD cơ bản (chọn Role dropdown, chọn Trạng thái, nút Xóa và nút Xác nhận Lưu), giao diện bảng `UsersView` xuất hiện thêm cột riêng `THAO TÁC` với độ rộng 140px và nút thùng rác màu đỏ đơn độc trên từng dòng. Việc có cả cột `NGÀY CẤP` riêng biệt và cột `THAO TÁC` khiến bảng bị dàn trải theo chiều ngang, chưa đạt được độ tinh gọn và thanh lịch.

Mục tiêu của spec này:
1. **Gộp thông tin:** Loại bỏ cột `NGÀY CẤP` riêng biệt. Đưa ngày tạo tài khoản thành dòng phụ (`Tham gia: dd/mm/yyyy`) ngay dưới địa chỉ email.
2. **Thiết kế lại Mini-Action Bar:** 
   - Thu nhỏ cột Thao tác xuống ~72px–80px.
   - Mặc định: Nút thùng rác mang màu xám nhạt trung tính (`textSubtle`), chỉ đổi sang màu đỏ (`error`) khi người dùng rê chuột (hover).
   - Khi có thay đổi (`isDirty`): Nút thùng rác chuyển đổi mượt mà thành cụm Mini Action Bar `[✔]` (Lưu) và `[✕]` (Hủy) cực kỳ nhỏ gọn, không làm xô lệch cấu trúc bảng.
   - Giữ nguyên các chốt chặn an toàn: Modal xác nhận trước khi xóa và bảo vệ Admin duy nhất của hệ thống.

---

## 2. User Stories

### [P1] Gộp Email và Ngày cấp thành Cụm Thông tin Tài khoản
- **As an Admin, I want to see the account creation date directly beneath the email address** so that the table saves an entire column while keeping all relevant metadata visible.
  - *Acceptance Criteria:*
    - Xóa bỏ cột tiêu đề và dữ liệu `NGÀY CẤP`.
    - Cột `EMAIL TÀI KHOẢN` hiển thị theo dạng 2 dòng:
      - Dòng 1: Địa chỉ Email (fontSize: 12-13, màu `textPrimary` hoặc `textSecondary`, fontWeight: w600).
      - Dòng 2: `Tham gia: dd/mm/yyyy` (fontSize: 11, màu `textMuted`, fontFamily: 'Manrope').
    - Bảng giảm từ 6 cột xuống còn 5 cột: `HỌ VÀ TÊN`, `EMAIL TÀI KHOẢN`, `VAI TRÒ`, `TRẠNG THÁI`, `THAO TÁC`.

### [P1] Tinh gọn Nút Xóa (Subtle Hover-Only Danger)
- **As an Admin, I want the delete button to look subtle by default and highlight in red only on hover** so that the interface does not feel cluttered or aggressive with red icons everywhere.
  - *Acceptance Criteria:*
    - Nút xóa mặc định hiển thị màu xám tinh tế (`AppColors.textSubtle` hoặc `AppColors.slate400`).
    - Khi rê chuột vào (Hover), icon chuyển sang màu đỏ `AppColors.error` kèm tooltip *"Xóa tài khoản"*.
    - Nếu là tài khoản Quản trị viên duy nhất (`isLastAdmin`), nút xóa hiển thị màu mờ (`AppColors.borderSoft` / disabled) kèm tooltip *"Không thể xóa Quản trị viên duy nhất"*.
    - Khi nhấn Xóa: Tiếp tục hiển thị modal xác nhận *"Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản [Tên] ([Email])? Hành động này không thể hoàn tác."*.

### [P1] Mini-Action Bar khi có Thay đổi Dữ liệu (Dirty State)
- **As an Admin, I want a sleek mini action bar [✔] [✕] to replace the delete button only when a row is edited** so that confirmation is compact and seamless.
  - *Acceptance Criteria:*
    - Cột Thao tác thu nhỏ độ rộng từ 140px xuống còn 72px – 80px.
    - Khi chưa thay đổi: Hiển thị nút Xóa xám tinh tế.
    - Khi có thay đổi Role hoặc Status (`isDirty`):
      - Nút xóa ẩn đi, thay thế bằng cụm 2 nút nhỏ:
        - Nút `[✔]` (Lưu): Icon checkmark trong khung pill nhỏ màu `primary` hoặc icon button xanh có tooltip *"Lưu thay đổi"*.
        - Nút `[✕]` (Hủy): Icon close nhỏ màu `textSubtle` có tooltip *"Hủy thay đổi"*.
      - Nhấn `[✔]` thực hiện gọi `PATCH /api/v1/users/{user_id}` qua `UsersApiClient`, hiển thị loading spinner nhỏ gọn (14-16px), cập nhật UI và hiển thị SnackBar thành công.
      - Nhấn `[✕]` khôi phục lại giá trị Role và Status ban đầu, đưa dòng về trạng thái clean.

---

## 3. UI Layout & Column Proportions

```
┌──────────────────┬──────────────────────────┬──────────────────────┬──────────────────────┬───────────┐
│ HỌ VÀ TÊN (flex 3)│ EMAIL TÀI KHOẢN (flex 3) │ VAI TRÒ (flex 2)     │ TRẠNG THÁI (flex 2)  │ THAO TÁC  │
├──────────────────┼──────────────────────────┼──────────────────────┼──────────────────────┼───────────┤
│ Đặng Quốc Huy    │ huy.dq22@student.edu.vn  │ [ Sinh viên ▾ ]      │ [ ✔ Hoạt động ▾ ]    │    🗑     │
│                  │ Tham gia: 25/09/2026     │                      │                      │           │
├──────────────────┼──────────────────────────┼──────────────────────┼──────────────────────┼───────────┤
│ Phạm Thu Trang   │ trang.pt21@student.edu.vn│ [ Giảng viên ▾ ]*    │ [ ✔ Hoạt động ▾ ]    │  ✔    ✕   │
│                  │ Tham gia: 25/09/2026     │                      │                      │           │
└──────────────────┴──────────────────────────┴──────────────────────┴──────────────────────┴───────────┘
```

---

## 4. Measurable Success Criteria

1. **Số lượng cột:** Giảm chính xác từ 6 cột xuống 5 cột.
2. **Độ rộng thao tác:** Thu gọn từ 140px về 72–80px.
3. **Màu sắc nút xóa:** 100% các nút xóa ở trạng thái tĩnh không dùng màu đỏ chói; chỉ chuyển đỏ khi hover.
4. **Kiểm tra mã nguồn:** Lệnh `flutter analyze` trong `jsm-fe` trả về `0 issues found`.
