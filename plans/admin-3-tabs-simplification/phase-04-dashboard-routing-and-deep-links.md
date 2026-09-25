# Phase 04: Dashboard Routing & Deep-Link Synchronization

**Phase ID:** `phase-04-dashboard-routing-and-deep-links`  
**Parent Plan:** [`plan.md`](file:///e:/jsm/jsm-fe/plans/admin-3-tabs-simplification/plan.md)  
**Spec Reference:** [`spec.md`](file:///e:/jsm/jsm-fe/plans/admin-3-tabs-simplification/spec.md) (FR-05)  
**Priority:** P1

---

## Objective

Rewire the main view router in [`AdminDashboardPage`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/pages/admin_dashboard_page.dart) to the new 3-tab index scheme (0..2), update all deep links from the Command Center and Header, and perform full codebase verification with `flutter analyze`.

---

## Tasks

1. **Update `AdminDashboardPage` Router:**
   - Case 0: `JournalsView` (Trung tâm Tạp chí)
   - Case 1: `StyleAndCorpusView` (Hồ sơ & Đối chuẩn NLP)
   - Case 2: `SystemAndDebugView` (Hệ thống & Kỹ thuật)
   - Remove obsolete index branches (3..7).
   - Extend `_navigateToTab` to optionally accept `subTabIndex` and `targetJournalId`.

2. **Update Deep Links in Child Views:**
   - In [`journal_command_center_panel.dart`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/widgets/journal_command_center_panel.dart):
     - Button *"Xem toàn diện & Đối chuẩn Corpus ➔"*: Route to Tab 1 (`onNavigateToTab(1)`).
     - Button *"Xem chi tiết logs ➔"*: Route to Tab 2 (`onNavigateToTab(2)`).
   - In [`admin_header.dart`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/widgets/admin_header.dart):
     - Update breadcrumb title mapping for indices 0, 1, 2.

3. **Verification:**
   - Run `flutter analyze` across `e:/jsm/jsm-fe`.
   - Ensure 0 errors, 0 warnings, and 0 analyzer issues.

---

## Verification & Acceptance Criteria

- Clicking any quick navigation action in the Command Center lands on the exact expected tab.
- Breadcrumbs in `AdminHeader` accurately reflect the active tab title.
- `flutter analyze` passes with 0 issues.
