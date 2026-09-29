# Spec: Admin Console Workflow & Pipeline UI Redesign

**Date:** 2026-09-25
**Status:** Ready

---

## Problem Statement

The current Admin Dashboard has misleading labels (e.g., "Không gian giảng viên", "Bản Thảo Của Tôi", "Thẩm định phản biện"), fake multi-role segregation for an app that only has 2 roles (`user` and `admin`), and static single-card views with severe whitespace issues (`maxWidth: 1080` on desktop). Admin users cannot intuitively operate or understand the 5-stage paper mining pipeline (`Journals ➔ Configs ➔ Jobs ➔ Snapshots ➔ Profiles`).

---

## User Stories

<!-- P1 = MVP (must ship), P2 = nice-to-have, P3 = future/out-of-scope -->

- **[P1]** As an Admin, I want to see an interactive Pipeline Overview dashboard on Tab 0 with live stage metrics (Journals, Active Jobs, Snapshots, Profiles) and direct click-through to each stage so that I immediately understand system status upon entering.
  Accepted when: Tab 0 renders a visual pipeline flow with KPI counters, quick actions ("Kích hoạt phân tích mới", "Đăng ký tạp chí"), and clicking any stage navigates to that corresponding tab.

- **[P1]** As an Admin, I want the sidebar organized by logical workflow groups (TỔNG QUAN, QUY TRÌNH KHAI PHÁ, HỆ THỐNG) with accurate Vietnamese labels reflecting real admin operations so that I can easily navigate the 8 modules without role confusion.
  Accepted when: All 8 sidebar items match their actual views (Tổng quan, Tạp chí khoa học, Cấu hình khai phá, Giám sát tác vụ, Kho Corpus Snapshots, Hồ sơ phong cách, Quản lý người dùng, Cài đặt).

- **[P1]** As an Admin, I want each pipeline view (Journals, Configurations, Job Monitor, Snapshots, Profiles Review) to expand across the full screen width and provide actionable data tables/lists with status badges (Queued/Running/Success/Failed) and direct controls instead of cramped static cards.
  Accepted when: Subviews fill available screen width without artificial 1080px constraints and display actionable data items with filter/search and controls.

- **[P2]** As an Admin, I want to filter and search journals by title/ISSN, jobs by status, and snapshots by journal name so that I can quickly locate specific artifacts.
  Accepted when: Search & filter bars update list state dynamically in each subview.

- **[P3]** Real-time WebSocket streaming of Grobid parsing logs in Job Monitor (out of scope for UI redesign phase; current polling/status refresh is sufficient).

---

## Functional Requirements

1. **FR-01: Redesign `AdminSidebar` navigation structure**
   - Group 1: **TỔNG QUAN**
     - Tab 0: `Tổng quan Pipeline` (OverviewView)
   - Group 2: **QUY TRÌNH KHAI PHÁ DỮ LIỆU**
     - Tab 1: `Danh mục Tạp chí` (JournalsView)
     - Tab 2: `Cấu hình khai phá` (ConfigurationsView)
     - Tab 3: `Giám sát tác vụ` (JobMonitorView)
     - Tab 4: `Kho Corpus Snapshots` (SnapshotsView)
     - Tab 5: `Hồ sơ phong cách` (ProfilesReviewView)
   - Group 3: **HỆ THỐNG**
     - Tab 7: `Quản lý người dùng` (UsersView)
     - Tab 6: `Cài đặt hệ thống` (SettingsView)

2. **FR-02: Overhaul `OverviewView` (Tab 0) into an Interactive Pipeline Dashboard**
   - **Header & Action Bar**: Quick action button "Kích hoạt phân tích mới" (`_showTriggerAnalysisDialog`) and "Đăng ký tạp chí".
   - **KPI Metric Strip**: 4 summary cards (`Tạp chí theo dõi`, `Tác vụ đang chạy / Hoàn tất`, `Bản chụp Corpus sẵn sàng`, `Tài khoản người dùng`).
   - **Visual Pipeline Flow Diagram**: Interactive 5-step stepper/card chain showing the stages:
     `1. Tạp chí ➔ 2. Cấu hình ➔ 3. Giám sát tác vụ ➔ 4. Kho Snapshot ➔ 5. Hồ sơ phong cách` with status indicators and click-to-navigate action on each step.
   - **Recent Activity Section**: Table/list of recent mining jobs with status pills (`Đang xử lý`, `Hoàn thành`, `Thất bại`) and execution timestamp.

3. **FR-03: Modernize and Un-constrain Pipeline Subviews**
   - Remove restrictive `ConstrainedBox(maxWidth: 1080)` across all views, allowing responsive padding that adapts to desktop screen widths.
   - Establish unified subview template:
     - Top: View Header (Title, Subtitle, Primary Action button).
     - Middle: Search, Status filter chips, and action shortcuts.
     - Body: Actionable Card Grid or Data Table with clear typography, status colors, and row actions.

4. **FR-04: Language & Terminology Harmonization**
   - Unify all UI copy in pure, professional Vietnamese (no random English cards like "Corpus snapshots" or "Journal management" inside Vietnamese pages).
   - Eliminate all references to "Không gian giảng viên", "Bản Thảo Của Tôi", and "Thẩm định phản biện" in Admin views.

---

## Non-Functional Requirements

- **Performance**: Zero UI jank during tab switching (< 16ms frame build).
- **Layout Consistency**: Uniform spacing (16/24/32px grid), typography (`Manrope`), and color tokens from `AppColors`.
- **Responsive Width**: Flawlessly adapts from 1200px laptop screens to 4K desktop screens without awkward white gaps or stretched text.

---

## Success Criteria

- [ ] 0 occurrences of misleading role labels in Admin views.
- [ ] All 8 sidebar items navigate to the correct corresponding view with 100% label-to-function accuracy.
- [ ] Tab 0 renders the interactive Pipeline Flow diagram, 4 KPI metric cards, and recent jobs list.
- [ ] Desktop screen space is gracefully utilized across all 8 subviews (no 1080px centering bottleneck).
- [ ] `flutter analyze` passes with 0 warnings or errors.

---

## Out of Scope

- Backend schema or API contract modifications (FastAPI backend remains untouched).
- Student manuscript checker frontend (`/student-checker`) logic.
- Authentication & SSO login workflows.

---

## Assumptions

- System operates exclusively with 2 roles: `user` (student/lecturer) and `admin` (operator).
- The existing backend endpoints (`/api/v1/admin/journals`, etc.) provide or will provide necessary data fields.
