# Phase 02: Pipeline Overview Dashboard Overhaul

**Phase ID:** `phase-02-overview-pipeline-dashboard`
**Status:** not_started
**Mapped Stories:** [P1] Interactive Pipeline Overview dashboard on Tab 0 (Lựa chọn A)

---

## Objectives

1. Completely rewrite `OverviewView` (Tab 0) to serve as an interactive, comprehensive mission control for the Admin.
2. Remove restrictive `ConstrainedBox(maxWidth: 1080)` and replace the fake "Bản Thảo Của Tôi" single-card.
3. Build 3 prominent UI components:
   - **4 KPI Metric Cards**: `Tạp chí theo dõi`, `Tác vụ đang chạy / Hoàn tất`, `Bản chụp Corpus sẵn sàng`, `Tài khoản người dùng`.
   - **Interactive 5-Step Pipeline Stepper**: Visual flow connecting:
     `1. Tạp chí (Journals) ➔ 2. Cấu hình (Configs) ➔ 3. Giám sát (Jobs) ➔ 4. Kho Snapshots ➔ 5. Hồ sơ phong cách (Profiles)`
     Each step has a status badge and an interactive `onTap` navigating to that step's tab.
   - **Quick Action & Recent Activity Section**: Table/list of recent jobs with status pills (Xanh/Vàng/Đỏ) and quick action buttons ("Kích hoạt phân tích mới", "Thêm tạp chí mới").

---

## Affected Files

- `lib/features/admin/presentation/views/overview_view.dart`
- Any helper widgets in `lib/features/admin/presentation/widgets/` if modularized.

---

## Tasks

1. In `overview_view.dart`:
   - Delete old static card copy ("Không gian giảng viên", "Bản Thảo Của Tôi").
   - Build responsive layout with `Padding(padding: EdgeInsets.all(28))`.
   - Implement `_buildMetricsRow()` with 4 modern KPI cards (with icons, counters, delta indicators).
   - Implement `_buildPipelineFlowCard()` with 5 sequential stages, visual chevron/arrow connectors, and click handlers calling `onNavigateToTab(index)`.
   - Implement `_buildRecentJobsSection()` with a clean table showing recent analysis tasks.
   - Connect "Kích hoạt phân tích mới" to `onTriggerNewAnalysis`.

---

## Acceptance Criteria

- [ ] Tab 0 renders the 4 KPI cards with real or realistic default counters.
- [ ] The 5-step pipeline diagram renders cleanly across desktop screen resolutions.
- [ ] Clicking any step in the pipeline diagram navigates to the respective tab (e.g. clicking "Kho Snapshots" jumps to Tab 4).
- [ ] Clicking "Kích hoạt phân tích mới" opens `_showTriggerAnalysisDialog`.
- [ ] No 1080px centering bottleneck or awkward white space.
