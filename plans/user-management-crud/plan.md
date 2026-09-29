# Plan: User Management Full CRUD with Inline Quick Actions

Mode: Fast
Risk: normal — updates user table fields (role, is_active, deletion) with safety checks for admin lockout

---

## Overview

This plan defines the end-to-end implementation of basic CRUD operations for user accounts in HyperData Lab:
1. **Phase 01: Backend User CRUD & Safety Guards (`jsm-be`)**
   - Add `UserUpdate` schema.
   - Implement `PATCH /api/v1/users/{user_id}` supporting `role`, `is_active`, and `full_name`.
   - Implement Admin lockout protection on `PATCH` and `DELETE` (cannot deactivate or delete the sole remaining active Admin).
   - Write pytest tests for `PATCH`, `DELETE`, and lockout validation.

2. **Phase 02: Frontend User Inline CRUD UI & API Client (`jsm-fe`)**
   - Update `UsersApiClient` with `updateUser` and robust `deleteUser`.
   - Update `UsersView` table:
     - Add `THAO TÁC` (Actions) column.
     - Inline dropdown for `VAI TRÒ` (Sinh viên, Giảng viên, Quản trị viên).
     - Inline dropdown for `TRẠNG THÁI` (Hoạt động, Tạm khóa).
     - Dirty row detection with prominent "Lưu" (Confirm/Save) button.
     - Delete button with confirmation modal.
     - Client-side admin lockout protection (cannot delete or deactivate own logged-in admin).

---

## Directory Structure

```
plans/user-management-crud/
  spec.md
  plan.md
  phase-01-backend-user-crud.md
  phase-02-frontend-user-inline-crud.md
```

## Phases

- `phase-01-backend-user-crud.md` — Backend endpoints, schemas, safety guards, and unit tests.
- `phase-02-frontend-user-inline-crud.md` — Frontend API client, interactive inline controls, confirmation modal, and UI tests.
