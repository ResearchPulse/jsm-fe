# Plan: Admin Console Workflow & Pipeline UI Redesign

**Date:** 2026-09-25
**Mode:** --fast
**Risk:** normal — multi-file Flutter UI overhaul, no schema/auth/infra risk
**Spec:** [spec.md](file:///e:/jsm/jsm-fe/plans/admin-ui-workflow-redesign/spec.md)

---

## Architecture & Design Decisions

1. **Pipeline-First Information Architecture**:
   - Reorder and re-label sidebar tabs to match the true end-to-end JSM lifecycle:
     `TỔNG QUAN (Tab 0) ➔ Tạp chí (Tab 1) ➔ Cấu hình (Tab 2) ➔ Giám sát tác vụ (Tab 3) ➔ Kho Snapshots (Tab 4) ➔ Hồ sơ phong cách (Tab 5) ➔ Quản lý người dùng (Tab 7) ➔ Cài đặt (Tab 6)`.
2. **Interactive Mission Control (Tab 0)**:
   - Transform `OverviewView` from a static card into an interactive pipeline flow diagram with live counters, quick trigger dialog, and click-through navigation to every stage.
3. **Responsive Un-constrained Layout**:
   - Remove `maxWidth: 1080` from all subviews; use responsive padding and flexible grid/column layouts so content breathes naturally on desktop resolutions.
4. **Pure Vietnamese Professional Copy**:
   - Eliminate all references to "Không gian giảng viên", "Bản Thảo Của Tôi", and "Thẩm định phản biện" from Admin views.

---

## Phases Breakdown

- [x] **Phase 01**: [Sidebar, Header & Navigation Reorganization](file:///e:/jsm/jsm-fe/plans/admin-ui-workflow-redesign/phase-01-sidebar-and-header.md)
  - Reorganize `AdminSidebar` into 3 groups with 100% accurate Vietnamese labels and icons.
  - Sync `AdminHeader` breadcrumbs and tab mappings with `AdminDashboardPage`.
- [x] **Phase 02**: [Pipeline Overview Dashboard Overhaul](file:///e:/jsm/jsm-fe/plans/admin-ui-workflow-redesign/phase-02-overview-pipeline-dashboard.md)
  - Replace `OverviewView` static card with KPI metrics strip, interactive 5-step pipeline flow card, and recent jobs list.
- [x] **Phase 03**: [Data Pipeline Subviews Modernization](file:///e:/jsm/jsm-fe/plans/admin-ui-workflow-redesign/phase-03-pipeline-views-modernization.md)
  - Modernize `JournalsView`, `ConfigurationsView`, `JobMonitorView`, `SnapshotsView`, and `ProfilesReviewView` with un-constrained responsive layouts, search/filter bars, and actionable lists.
- [x] **Phase 04**: [System Views, Language Harmonization & QA](file:///e:/jsm/jsm-fe/plans/admin-ui-workflow-redesign/phase-04-system-views-and-qa.md)
  - Polish `UsersView` and `SettingsView`, conduct anti-slop copy audit, and drive `flutter analyze` to 0 errors.

---

## Dependencies & Risks

- Tab index routing in `AdminDashboardPage` must remain synchronized with `_selectedIndex` across all views.
- Subviews must consume existing repository/bloc layers without modifying backend API contracts.

---

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-09-25 18:36
**Phase in progress:** Completed all phases (Phase 01 - Phase 04)
**Status:** All 4 phases successfully implemented, verified with `flutter analyze` (0 errors), and ready for live inspection.

### Decisions made this session
- Reorganized Sidebar into 3 authentic Admin groups: TỔNG QUAN, QUY TRÌNH KHAI PHÁ DỮ LIỆU, HỆ THỐNG.
- Overhauled OverviewView (Tab 0) with a live 5-stage interactive pipeline flow, 4 KPI counters, and recent jobs table.
- Un-constrained all 5 pipeline subviews and 2 system views, eliminating 1080px centering bottlenecks.
- Unified 100% of copy across all Admin views in professional Vietnamese.

### Next immediate action
Hot restart the Flutter application (`R`) to enjoy the sleek, newly redesigned Admin Console!
