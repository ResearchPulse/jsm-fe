# Phase 01: Backend User CRUD & Safety Guards

**ID:** `phase-01-backend-user-crud`  
**Target:** `jsm-be` (`app/modules/users`)  
**Priority:** P1  
**Status:** Completed  

---

## Objective

Provide reliable RESTful API endpoints for updating user fields (`role`, `is_active`, `full_name`) and deleting users, with categorical safety checks to prevent Admin lockout.

---

## Tasks

1. **Add `UserUpdate` schema in `app/modules/users/schemas.py`:**
   ```python
   class UserUpdate(BaseModel):
       full_name: Optional[str] = Field(None, min_length=2, max_length=255)
       role: Optional[str] = Field(None, description="student, lecturer, or admin")
       is_active: Optional[bool] = Field(None, description="Active status")
   ```
2. **Implement `PATCH /api/v1/users/{user_id}` in `app/modules/users/router.py`:**
   - Fetch target user by `user_id`, raise 404 if not found.
   - If `role` is provided, validate it belongs to `['student', 'lecturer', 'admin']`.
   - **Admin Safety Check:**
     - If the target user currently has `role == "admin"` AND (`req.is_active is False` OR (`req.role is not None` and `req.role != "admin"`)):
       - Count active admins in DB: `db.query(User).filter(User.role == "admin", User.is_active.is_(True)).count()`.
       - If count $\le 1$, raise `HTTPException(400, "Không thể khóa hoặc hạ quyền Quản trị viên cuối cùng của hệ thống.")`.
   - Update modified fields and commit.
   - Return `SuccessResponse[UserResponse]`.
3. **Enhance `DELETE /api/v1/users/{user_id}` in `app/modules/users/router.py`:**
   - **Admin Safety Check:**
     - If target user has `role == "admin"`:
       - Count active admins in DB.
       - If count $\le 1$, raise `HTTPException(400, "Không thể xóa tài khoản Quản trị viên cuối cùng của hệ thống.")`.
   - Delete user, commit, and return `SuccessResponse[None]`.
4. **Automated Testing:**
   - Create tests in `tests/test_users_crud.py` testing update role, update status, lockout rejection, and deletion.

---

## Verification Command

```bash
pytest tests/ -k user
```
