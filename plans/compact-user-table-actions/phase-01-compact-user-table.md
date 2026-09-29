# Phase 01: Tinh gọn Bảng Quản lý Người dùng & Mini-Action Bar

**ID:** `phase-01-compact-user-table`  
**Target:** `jsm-fe` (`lib/features/users/presentation/views/users_view.dart`)  
**Priority:** P1  
**Status:** Completed  

---

## Objective

Cập nhật `UsersView` nhằm gộp thông tin Ngày cấp vào cột Email, loại bỏ cột riêng, thu hẹp cột thao tác về 72–80px, đổi màu nút xóa tĩnh sang xám tinh tế (hover đỏ), và tích hợp Mini-Action Bar `[✔]` `[✕]` khi có thay đổi.

---

## Tasks

1. **Gộp Cột Ngày Cấp vào Email (`UsersView`):**
   - Loại bỏ tiêu đề `NGÀY CẤP` trong `_buildTableHeader`.
   - Cập nhật cell Email trong `_buildUserRow`:
     - Cột `flex: 3` (hoặc `flex: 4` nếu muốn thoáng) hiển thị `Column(crossAxisAlignment: CrossAxisAlignment.start, ...)`:
       - Dòng 1: `Text(email, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary, fontFamily: 'Manrope'))`.
       - Dòng 2: `Text('Tham gia: ${_formatDate(...)}', style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Manrope'))`.
   - Loại bỏ cell `NGÀY CẤP` riêng biệt.

2. **Thiết kế lại Nút Xóa (Subtle Hover-Only Danger):**
   - Thay đổi icon button xóa ở trạng thái clean:
     - Dùng `IconButton` với icon `Icons.delete_outline_rounded` (size 18).
     - Màu sắc: Dùng icon color xám `AppColors.textSubtle` (hoặc hover color `AppColors.error`).
     - Tooltip: `isLastAdmin ? 'Không thể xóa Quản trị viên duy nhất' : 'Xóa tài khoản'`.

3. **Thiết kế Mini-Action Bar khi Dirty:**
   - Thu hẹp `SizedBox` cột Thao tác thành `width: 76` (hoặc `width: 80`).
   - Khi `isDirty`:
     - Hiển thị `Row(mainAxisSize: MainAxisSize.min, children: [...])`:
       - Nút Lưu: Một container mini-pill hoặc IconButton gọn gàng:
         - Nút tròn/bo góc nhỏ với background `AppColors.primary`, icon `Icons.check_rounded` màu trắng (size 15).
         - Tooltip: `"Lưu thay đổi"`.
         - Khi nhấn gọi `_saveUserChanges(userId, email, fullName)`.
       - Nút Hủy: Nút nhỏ icon `Icons.close_rounded` màu `AppColors.textSubtle` (size 16).
         - Tooltip: `"Hủy thay đổi"`.
         - Khi nhấn gọi `_discardUserChanges(userId)`.
   - Khi `isSaving || isDeleting`: Hiển thị `CircularProgressIndicator` nhỏ 16px.

4. **Kiểm tra linter & giao diện:**
   - Chạy `flutter analyze` đảm bảo 0 errors.

---

## Verification Command

```bash
flutter analyze e:\jsm\jsm-fe\lib\features\users
```
