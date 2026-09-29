# Phase 02: Frontend User Inline CRUD UI & API Client

**ID:** `phase-02-frontend-user-inline-crud`  
**Target:** `jsm-fe` (`lib/features/users`)  
**Priority:** P1  
**Status:** Completed  

---

## Objective

Deliver an ergonomic, 1-click inline CRUD experience on `UsersView` allowing administrators to change user roles, toggle account active status, confirm modifications with a dedicated save button, and delete users safely.

---

## Tasks

1. **Update `UsersApiClient` (`lib/features/users/data/datasources/users_api_client.dart`):**
   - Add `updateUser(String userId, {String? role, bool? isActive, String? fullName})`:
     - Calls `PATCH ${ApiEndpoints.users}/$userId` with JSON body.
     - Parses and returns updated user map, or throws `ServerException`.
   - Update `deleteUser(String userId)` to return `Future<bool>` and throw on HTTP error $\ge 400$.
2. **Update `UsersView` (`lib/features/users/presentation/views/users_view.dart`):**
   - Track local changes per row:
     - `Map<String, String> _editedRoles = {};` (userId -> new role)
     - `Map<String, bool> _editedStatuses = {};` (userId -> new status)
     - `Set<String> _savingUserIds = {};`
     - `Set<String> _deletingUserIds = {};`
   - **VAI TRÒ Column:**
     - Replace static text with an inline Dropdown selector:
       - Options: `student` (Sinh viên), `lecturer` (Giảng viên), `admin` (Quản trị viên).
       - Visual: Styled badge pill with custom dropdown arrow.
       - Selecting a new value updates `_editedRoles[userId]`.
   - **TRẠNG THÁI Column:**
     - Replace static text with an inline Dropdown selector:
       - Options: `true` (Hoạt động / Active), `false` (Tạm khóa / Suspended).
       - Visual: Green icon for active, amber/red icon for suspended.
       - Selecting a new value updates `_editedStatuses[userId]`.
   - **THAO TÁC Column:**
     - Add `THAO TÁC` header column.
     - If row has dirty changes (`_editedRoles.containsKey(userId) || _editedStatuses.containsKey(userId)`):
       - Show **"Lưu thay đổi"** button (`Icons.check_rounded` or text button with primary styling).
       - Clicking "Lưu" calls `_apiClient.updateUser` with loading spinner, shows floating SnackBar, updates local user list, and clears dirty state.
       - Cancel icon to discard changes back to original.
     - **Nút Xóa (Delete Button):**
       - Red trash icon button (`Icons.delete_outline_rounded`).
       - Clicking opens confirmation dialog:
         - Title: *"Xác nhận xóa tài khoản"*
         - Message: *"Bạn có chắc chắn muốn xóa vĩnh viễn tài khoản [Tên] ([Email])? Hành động này không thể hoàn tác."*
         - Buttons: "Hủy bỏ" & "Xóa vĩnh viễn" (Red).
       - Calling `deleteUser` removes row from list and shows confirmation SnackBar.
3. **Safety Protection:**
   - Detect if target user is current user's email/id or sole admin; disable delete button with tooltip *"Không thể xóa tài khoản Quản trị viên này"*.

---

## Verification Command

```bash
flutter analyze
```
