# Plan: Admin UI Simplification & Real-Time Progress Experience

**Date:** 2026-09-26  
**Mode:** --fast  
Risk: normal — Frontend UI component simplification and pagination additions with zero API/schema breaking changes.

---

## Architecture Overview

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ HyperData Lab Admin Console (Streamlined & User-First)                                │
├─────────────────────┬──────────────────────────────────────────────────────────────────┤
│ Minimalist Sidebar  │ Active Simplified Workspace                                      │
├─────────────────────┼──────────────────────────────────────────────────────────────────┤
│ 1. Trung tâm        │ [Tab 0] JournalsView with Command Center                         │
│    Tạp chí          │ - Left: 40% Catalog with 6-item Pagination (< Trang 1 / 3 >)    │
│                     │ - Right: 60% 1-Touch Mining, "Đang phân tích" Real-Time Card     │
│                     │   (Showing exact article being analyzed, zero technical bloat)   │
├─────────────────────┼──────────────────────────────────────────────────────────────────┤
│ 2. Hồ sơ &          │ [Tab 1] StyleAndCorpusView                                       │
│    Đối chuẩn NLP    │ - Top Segmented Switcher: Style Profiles vs Corpus Snapshots     │
├─────────────────────┼──────────────────────────────────────────────────────────────────┤
│ 3. Hệ thống &       │ [Tab 2] SystemAndDebugView (Decluttered)                         │
│    Kỹ thuật         │ - Job Monitor without 6-stage diagram, clean task list           │
│                     │ - Services Settings & Users Admin                                │
└─────────────────────┴──────────────────────────────────────────────────────────────────┘
```

---

## Phases Overview

| Phase | Filename | Objective | Key Deliverables | Status |
| :--- | :--- | :--- | :--- | :--- |
| **01** | `phase-01-pagination-and-header-cleanup.md` | Catalog Pagination & Header Clean-up | Add 6-item pagination with footer controls to left column of `JournalsView`; remove `Kích hoạt phân tích` button from `AdminHeader` | `[x] Completed` |
| **02** | `phase-02-realtime-analysis-card.md` | Real-time "Đang phân tích" Progress Card | Replace 4-box technical pipeline with clean "Đang phân tích" card in `JournalCommandCenterPanel`, displaying live current article in progress | `[x] Completed` |
| **03** | `phase-03-system-debug-declutter.md` | System & Debug Tab Decluttering | Remove 6-stage diagram and duplicate action button from `JobMonitorView`; verify all 3 sub-tabs render cleanly | `[x] Completed` |

---

## Dependencies & Design Tokens

- Design System: `AppColors.surface`, `AppColors.surfaceSoft`, `AppColors.primary`, `AppColors.borderSoft`
- Typography: `Manrope`
- Verification Command: `flutter analyze`

---

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-09-26 02:38  
**Phase in progress:** All 3 phases completed  
**Status:** All deliverables implemented and verified with 0 analyzer issues

### Decisions made this session
- Implemented 6-item pagination with `< Trang 1 / 3 >` footer controls in `JournalsView` and auto-reset to page 1 on query/filter changes.
- Removed redundant `Kích hoạt phân tích` button from `AdminHeader`.
- Replaced 4-box technical pipeline card with a human-friendly "Đang phân tích" card in `JournalCommandCenterPanel` displaying real-time article title and progress percentage.
- Decluttered `JobMonitorView` by removing the 6-stage stepper and duplicate action button.

### Verification Evidence
- `flutter analyze`: No issues found! (0 errors, 0 warnings across all files).
