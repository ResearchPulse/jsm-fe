# Phase 03: Data Pipeline Subviews Modernization

**Phase ID:** `phase-03-pipeline-views-modernization`
**Status:** not_started
**Mapped Stories:** [P1, P2] Modernize subviews for Journals, Configurations, Job Monitor, Snapshots, and Profiles Review

---

## Objectives

1. Remove `ConstrainedBox(maxWidth: 1080)` and single-static-card pattern across:
   - `JournalsView` (Tab 1)
   - `ConfigurationsView` (Tab 2)
   - `JobMonitorView` (Tab 3)
   - `SnapshotsView` (Tab 4)
   - `ProfilesReviewView` (Tab 5)
2. Introduce a unified subview layout template:
   - Header with title, context subtitle, and primary action button.
   - Filter & search toolbar.
   - Actionable data list or table with status badges and clear typography.
3. Translate all remaining English strings to professional Vietnamese.

---

## Affected Files

- `lib/features/admin/presentation/views/journals_view.dart`
- `lib/features/admin/presentation/views/configurations_view.dart`
- `lib/features/admin/presentation/views/job_monitor_view.dart`
- `lib/features/admin/presentation/views/snapshots_view.dart`
- `lib/features/admin/presentation/views/profiles_review_view.dart`

---

## Tasks

1. In `journals_view.dart`:
   - Replace empty placeholder card with an actionable Journals Data Table (Title, ISSN, Domain, Papers Count, Actions).
   - Add Search field and "Đăng ký tạp chí" action button.
2. In `configurations_view.dart`:
   - Provide sampling configuration cards (Year range 2021-2024, Target paper counts, Grobid parsing rules).
3. In `job_monitor_view.dart`:
   - Display active & historical jobs with status pills (`Đang xử lý`, `Hoàn thành`, `Thất bại`), progress bar (e.g. 78%), duration, and Grobid parsing stage indicator.
4. In `snapshots_view.dart`:
   - Display immutable snapshot versions for journals with paper count, checksum/hash, creation date, and baseline status badge.
5. In `profiles_review_view.dart`:
   - Display stance distribution bars (Support / Neutral / Contradict), rhetorical moves breakdown (CARS model: Move 1, 2, 3), and hedges/boosters ratio gauges.

---

## Acceptance Criteria

- [ ] All 5 subviews utilize available desktop width with responsive padding.
- [ ] Subviews feature functional UI components (search bar, filter chips, actionable table/cards).
- [ ] 0 English strings remaining in Vietnamese views.
