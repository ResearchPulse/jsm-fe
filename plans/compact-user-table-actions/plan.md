# Plan: Tinh gọn Bảng Quản lý Người dùng & Mini-Action Bar

Mode: Fast
Risk: tiny — single-file frontend presentation enhancement in `users_view.dart`, fully reversible

---

## Overview

Plan này hiện thực hóa spec tinh gọn bảng `UsersView`:
1. Gộp cột `NGÀY CẤP` thành dòng phụ (`Tham gia: dd/mm/yyyy`) dưới `EMAIL TÀI KHOẢN`.
2. Giảm bảng từ 6 cột xuống 5 cột.
3. Thu gọn cột Thao tác còn 72–80px.
4. Nút Xóa mang màu xám tinh tế (`textSubtle`), chuyển màu đỏ (`error`) khi hover.
5. Khi có thay đổi (`isDirty`): Hiển thị Mini-Action Bar gồm nút `[✔]` (Lưu) và `[✕]` (Hủy) cực kỳ nhỏ gọn thay thế nút xóa.

---

## Directory Structure

```
plans/compact-user-table-actions/
  spec.md
  plan.md
  phase-01-compact-user-table.md
```

## Phases

- `phase-01-compact-user-table.md` — Cập nhật UI `UsersView` gộp cột ngày cấp và tích hợp Mini-Action Bar.
