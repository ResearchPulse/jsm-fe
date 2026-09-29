# Spec: User Management Full CRUD with Inline Quick Actions

**Date:** 2026-09-26  
**Status:** Ready for Planning  
**Target Module:** `jsm-fe` (`UsersView`, `UsersApiClient`) & `jsm-be` (`app.modules.users`)

---

## 1. Problem Statement

In the HyperData Lab Admin Console, the **User Management** screen (`UsersView`) currently only supports listing accounts and creating new accounts (Student/Lecturer). It completely lacks fundamental CRUD capabilities:
1. **No Account Deletion:** Unable to delete spam, test, or ex-student/faculty accounts.
2. **No Status Toggle:** Accounts are locked into a permanent "Hoạt động" (Active) state with no way to suspend/deactivate accounts.
3. **No Role Update:** Unable to promote a student to lecturer/admin or change access permissions without deleting and recreating the account from scratch.

This spec defines a streamlined **Inline Quick Actions CRUD workflow** on the User Management table:
- Direct dropdown selection for **Role** (`student`, `lecturer`, `admin`) on each row.
- Direct dropdown selection for **Status** (`Active`, `Suspended/Khóa`) on each row.
- Inline **Confirmation / Save button** when row state changes to prevent accidental edits.
- Direct **Delete button** with confirmation dialog and strict **Admin lockout protection guards**.

---

## 2. User Stories

### [P1] Inline Role Update
- **As an Admin, I want to change a user's role directly on their table row** so that I can promote or demote permissions in 1–2 clicks without navigating away.
  - *Acceptance Criteria:*
    - Clicking the Role column shows a Dropdown menu with:
      - `Sinh viên (Student)` (`#0D9488`)
      - `Giảng viên (Lecturer)` (`#0071BC`)
      - `Quản trị viên (Admin)` (`#7C3AED`)
    - When a different role is selected, a confirmation/save action is prompted or displayed on the row before applying the change.
    - Successfully changing the role updates the backend and displays a success toast.

### [P1] Inline Status Toggle (Active / Suspended)
- **As an Admin, I want to toggle a user's active status directly on their table row** so that I can instantly revoke access for accounts under review or suspended students.
  - *Acceptance Criteria:*
    - The Status column provides a dropdown or selector:
      - `Hoạt động (Active)` with Green checkmark icon.
      - `Tạm khóa (Suspended)` with Amber/Red cancel icon.
    - When changed, the inline confirmation button illuminates or prompts confirmation.
    - Applying the change calls `PATCH /api/v1/users/{user_id}` and updates `is_active` in DB.

### [P1] Account Deletion with Safety Confirmation
- **As an Admin, I want to delete a user account with a confirmation prompt** so that I can purge obsolete accounts safely.
  - *Acceptance Criteria:*
    - An action column at the end of each row contains a Delete button (red trash icon `Icons.delete_outline_rounded`).
    - Clicking Delete opens a confirmation dialog: *"Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản [Full Name] ([Email])? Hành động này không thể hoàn tác."*
    - Clicking "Xác nhận xóa" calls `DELETE /api/v1/users/{user_id}`, removes the user from the table immediately, and displays a success toast.

### [P1] Critical Admin Lockout Guard
- **As a System Architect, I want to prevent deletion or deactivation of the last Admin account** so that the system is never rendered unmanageable.
  - *Acceptance Criteria:*
    - If the user being modified is an `admin` and `db.query(User).filter(role == 'admin', is_active == True).count() <= 1`, any attempt to delete or set `is_active=False` or `role != 'admin'` returns `HTTP 400 Bad Request` with message: *"Không thể xóa hoặc khóa tài khoản Quản trị viên cuối cùng của hệ thống."*
    - Frontend disables or hides delete/deactivate actions for the current user's own logged-in account.

---

## 3. Functional Requirements

### FR-01: Backend API Enhancements (`jsm-be/app/modules/users`)
- **Schema `UserUpdate` in `schemas.py`:**
  ```python
  class UserUpdate(BaseModel):
      full_name: Optional[str] = None
      role: Optional[str] = None # 'student' | 'lecturer' | 'admin'
      is_active: Optional[bool] = None
  ```
- **Endpoint `PATCH /api/v1/users/{user_id}`:**
  - Validates `user_id` exists in PostgreSQL.
  - Validates `role` is one of `['student', 'lecturer', 'admin']` if provided.
  - Enforces Admin protection: counts active admins before applying `role` or `is_active` changes.
  - Updates fields and timestamps, commits, and returns updated `UserResponse`.
- **Endpoint `DELETE /api/v1/users/{user_id}`:**
  - Enforces Admin protection: prevents deleting the sole remaining active admin.
  - Deletes user row and returns success response.

### FR-02: Frontend API Client (`jsm-fe/lib/features/users/data/datasources/users_api_client.dart`)
- Add method:
  ```dart
  Future<Map<String, dynamic>> updateUser(
    String userId, {
    String? role,
    bool? isActive,
    String? fullName,
  });
  ```
- Enhance `deleteUser(String userId)` to return `Future<bool>` and handle error responses gracefully.

### FR-03: Frontend Inline UI (`UsersView` in `users_view.dart`)
- Add **THAO TÁC** column (Width: ~140px) to the table header.
- On each user row:
  - **VAI TRÒ (Role Dropdown):**
    - A custom styled dropdown showing current role badge.
    - When changed, records draft change for that row.
  - **TRẠNG THÁI (Status Dropdown):**
    - A custom styled dropdown: `Hoạt động` / `Tạm khóa`.
    - When changed, records draft change for that row.
  - **NÚT XÁC NHẬN LƯU (Confirm Save):**
    - When a row has unsaved changes (`isDirty`), an animated "Lưu" button (green check icon or elevated button) appears in the actions cell.
    - Clicking it executes `updateUser` with a loading indicator, then marks the row clean.
  - **NÚT XÓA (Delete Button):**
    - Outlined or icon button with red tint.
    - Opens standard confirmation dialog before calling `deleteUser`.
    - Disabled if user is the current active admin.

---

## 4. Non-Functional Requirements

- **Design Harmony:** Must strictly follow the clean, professional, monochrome research-grade look (`AppColors.surface`, `AppColors.border`, `AppColors.textPrimary`), avoiding garish rainbow colors.
- **Latency & Responsiveness:** Inline update reflects instantly ($\le 300\text{ms}$) with optimistic UI or smooth loading indicator on the row.
- **Error Handling:** Network errors or backend validation rejections display a floating SnackBar without corrupting local UI state.

---

## 5. Success Metrics

1. An Admin can change a user's role and save in $\le 2$ clicks.
2. An Admin can deactivate an account in $\le 2$ clicks.
3. System categorically prevents accidental removal of all admin credentials (100% lockout proof).
