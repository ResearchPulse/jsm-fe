# Phase 01: Sidebar, Header & Navigation Reorganization

**Phase ID:** `phase-01-sidebar-and-header`
**Status:** not_started
**Mapped Stories:** [P1] Accurate sidebar navigation and tab synchronization

---

## Objectives

1. Reorganize `AdminSidebar` items into 3 clear groups:
   - **TỔNG QUAN**: Tab 0 - Tổng quan Pipeline (Overview)
   - **QUY TRÌNH KHAI PHÁ DỮ LIỆU**:
     - Tab 1: Danh mục Tạp chí (Journals)
     - Tab 2: Cấu hình khai phá (Configurations)
     - Tab 3: Giám sát tác vụ (Job Monitor)
     - Tab 4: Kho Corpus Snapshots (Snapshots)
     - Tab 5: Hồ sơ phong cách (Profiles Review)
   - **HỆ THỐNG**:
     - Tab 7: Quản lý người dùng (Users)
     - Tab 6: Cài đặt hệ thống (Settings)
2. Update `AdminHeader` to display accurate breadcrumbs and titles for each selected tab (e.g. "Khai phá dữ liệu / Danh mục Tạp chí" instead of "Giảng viên / Bản thảo").
3. Verify `AdminDashboardPage` tab routing switch statement matches the updated index order.

---

## Affected Files

- `lib/features/admin/presentation/widgets/admin_sidebar.dart`
- `lib/features/admin/presentation/widgets/admin_header.dart`
- `lib/features/admin/presentation/pages/admin_dashboard_page.dart`

---

## Tasks

1. In `admin_sidebar.dart`:
   - Replace old section headers ("KHÔNG GIAN GIẢNG VIÊN", "THẨM ĐỊNH PHẢN BIỆN", "HỆ THỐNG").
   - Update titles and icons for tabs 0 through 7 according to the pipeline order.
2. In `admin_header.dart`:
   - Update the title mapping switch case to output correct breadcrumb and page title based on `selectedIndex`.
3. In `admin_dashboard_page.dart`:
   - Ensure `_navigateToTab` and `_buildActiveView` correspond seamlessly to the updated indexes.

---

## Acceptance Criteria

- [ ] Sidebar displays 3 clean section headers in Vietnamese.
- [ ] Clicking any of the 8 menu items highlights the active item and switches to the correct subview.
- [ ] Header breadcrumb and title instantly reflect the active tab.
- [ ] Zero compile/analyze errors.
