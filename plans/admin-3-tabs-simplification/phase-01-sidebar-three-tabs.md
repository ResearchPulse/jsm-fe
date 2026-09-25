# Phase 01: Minimalist 3-Item Sidebar & Default Landing View

**Phase ID:** `phase-01-sidebar-three-tabs`  
**Parent Plan:** [`plan.md`](file:///e:/jsm/jsm-fe/plans/admin-3-tabs-simplification/plan.md)  
**Spec Reference:** [`spec.md`](file:///e:/jsm/jsm-fe/plans/admin-3-tabs-simplification/spec.md) (FR-01, FR-02)  
**Priority:** P1

---

## Objective

Trim [`admin_sidebar.dart`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/widgets/admin_sidebar.dart) from 8 navigation items down to **exactly 3 clean, purposeful navigation items**, and set Tab 0 (`Trung tâm Tạp chí`) as the default view on launch in [`admin_dashboard_page.dart`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/pages/admin_dashboard_page.dart).

---

## Tasks

1. **Refactor `AdminSidebar` Menu Items:**
   - Item 0: `Icons.auto_stories_outlined` / `Icons.auto_stories_rounded` — **`Trung tâm Tạp chí`**
   - Item 1: `Icons.psychology_outlined` / `Icons.psychology_rounded` — **`Hồ sơ & Đối chuẩn NLP`**
   - Item 2: `Icons.tune_outlined` / `Icons.tune_rounded` — **`Hệ thống & Kỹ thuật`**
   - Remove obsolete section headers (`TỔNG QUAN`, `QUY TRÌNH KHAI PHÁ`, `HỆ THỐNG`) to achieve a modern, uncluttered look.
   - Maintain brand logo ("H" HyperData Lab), collapse toggle button, and logout area.

2. **Default Landing State:**
   - In `AdminDashboardPage`, initialize `_selectedIndex = 0` so the application directly mounts the Journal Command Center upon opening.

---

## Verification & Acceptance Criteria

- Sidebar displays exactly 3 menu items with smooth active selection states.
- App boots up directly to "Trung tâm Tạp chí" without requiring manual clicks.
- `flutter analyze` passes cleanly.
