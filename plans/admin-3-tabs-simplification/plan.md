# Plan: Admin Navigation Simplification (3-Tab Core Architecture)

**Date:** 2026-09-26  
**Mode:** --fast  
Risk: normal — Refactors frontend navigation sidebar and introduces two composite sub-tab views without schema or API contract changes.

---

## Architecture Overview

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ HyperData Lab Admin Console                                                            │
├─────────────────────┬──────────────────────────────────────────────────────────────────┤
│ Minimalist Sidebar  │ Active Composite View Workspace                                  │
│ (3 Core Items)      │                                                                  │
├─────────────────────┼──────────────────────────────────────────────────────────────────┤
│ 1. Trung tâm        │ [Tab 0 - Default] JournalsView with Command Center               │
│    Tạp chí          │ - Left: 40% Journal Catalog                                      │
│                     │ - Right: 60% 1-Touch Mining, 4-Stage Stepper, Quick NLP Profile  │
├─────────────────────┼──────────────────────────────────────────────────────────────────┤
│ 2. Hồ sơ &          │ [Tab 1] StyleAndCorpusView (Segmented Switcher):                 │
│    Đối chuẩn NLP    │ ├─ Sub-tab A: Hồ sơ phong cách & Rhetorical Moves (Member 3 NLP) │
│                     │ └─ Sub-tab B: Kho bài & Corpus Snapshots (Datasets & Reference)  │
├─────────────────────┼──────────────────────────────────────────────────────────────────┤
│ 3. Hệ thống &       │ [Tab 2] SystemAndDebugView (Segmented Switcher):                 │
│    Kỹ thuật         │ ├─ Sub-tab A: Nhật ký tác vụ & Debug (Job Monitor, Logs, Retry)  │
│                     │ └─ Sub-tab B: Cài đặt dịch vụ & Người dùng (MinIO, GROBID, OpenAlex) │
└─────────────────────┴──────────────────────────────────────────────────────────────────┘
```

---

## Phases Overview

| Phase | Filename | Objective | Key Deliverables | Status |
| :--- | :--- | :--- | :--- | :--- |
| **01** | `phase-01-sidebar-three-tabs.md` | Minimalist 3-Item Sidebar & Default Landing | Refactor `AdminSidebar` to 3 clean items, remove outdated sections, set initial index to 0 | `[x] Completed` |
| **02** | `phase-02-style-corpus-composite-view.md` | Unified Style & Corpus Analytics Hub | Build `StyleAndCorpusView` combining `ProfilesReviewView` + `SnapshotsView` with top segmented switcher | `[x] Completed` |
| **03** | `phase-03-system-debug-composite-view.md` | Unified System Monitor & Settings Hub | Build `SystemAndDebugView` combining `JobMonitorView` + `SettingsView` + `UsersView` with segmented switcher | `[x] Completed` |
| **04** | `phase-04-dashboard-routing-and-deep-links.md` | Dashboard Router & Deep-Link Synchronization | Update `AdminDashboardPage` router (0..2), rewire Command Center action links, verify with `flutter analyze` | `[x] Completed` |

---

## Dependencies & Design Tokens

- Design System: `AppColors.sidebarBackground`, `AppColors.primary`, `AppColors.surfaceSoft`, `AppColors.borderSoft`
- Typography: `Manrope`
- Routing: Clean `onNavigateToTab(int tabIndex, {int? subTabIndex, String? targetJournalId})`

---

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-09-26 02:21  
**Phase in progress:** All 4 phases completed  
**Status:** All deliverables implemented and verified with 0 analyzer issues

### Decisions made this session
- Refactored `AdminSidebar` to exactly 3 core navigation items (`Trung tâm Tạp chí`, `Hồ sơ & Đối chuẩn NLP`, `Hệ thống & Kỹ thuật`).
- Set Tab 0 (`JournalsView` Command Center) as the default view on application boot.
- Created `StyleAndCorpusView` (Tab 1) uniting Member 3's NLP style analytics and Corpus Snapshots.
- Created `SystemAndDebugView` (Tab 2) uniting Job Monitor logs, article retry actions, service settings, and users.
- Updated all deep-link shortcuts in `JournalCommandCenterPanel`, `JournalsView`, and `AdminHeader`.

### Verification Evidence
- `flutter analyze`: No issues found! (0 errors, 0 warnings across all files).

