# Plan: Journal All-in-One Command Center (Minimal Actions & Unified Pipeline UX)

**Date:** 2026-09-26  
**Mode:** --fast  
Risk: normal — Adds a master-detail side panel to `JournalsView` and hooks into existing job/config/nlp APIs with zero schema risk.

---

## Architecture Overview

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ JournalsView (Master-Detail Responsive Workspace)                                      │
├─────────────────────────────────────────┬──────────────────────────────────────────────┤
│ Left Panel: Journal Catalog (38%)       │ Right Panel: Command Center (62%)            │
│                                         │                                              │
│ - Search & Domain / Status Filters      │ 1. Selected Journal Hero Card                │
│ - Journal Card List                     │ 2. 1-Touch Preset Action                     │
│   (Click card -> Select as Active)      │    [ ▶ Bắt đầu Khai phá & Phân tích ]        │
│                                         │ 3. Pipeline Stepper (Live Realtime Status):  │
│                                         │    [OpenAlex] ➔ [Grobid] ➔ [Normalizer]      │
│                                         │ 4. NLP Style Profile Quick View:             │
│                                         │    - Sentence lengths, Stance, Voice metrics │
└─────────────────────────────────────────┴──────────────────────────────────────────────┘
```

---

## Phases Overview

| Phase | Filename | Objective | Key Deliverables | Status |
| :--- | :--- | :--- | :--- | :--- |
| **01** | `phase-01-master-detail-layout.md` | Master-Detail Structure in `JournalsView` | Responsive 2-column split, selected journal state, empty placeholder | `[x] Completed` |
| **02** | `phase-02-command-center-controls.md` | 1-Touch Preset Execution | Instant trigger (auto-config + start job), collapsible advanced settings | `[x] Completed` |
| **03** | `phase-03-realtime-stepper-and-polling.md` | Real-time 4-Stage Stepper | Animated pipeline progress, article counters, automatic 2s polling | `[x] Completed` |
| **04** | `phase-04-nlp-style-profile-card.md` | Instant NLP Profile Display | Auto-render Style Profile summary on job completion, Hyland stance, Voice | `[x] Completed` |

---

## Dependencies & API Integration

- `AdminApiClient`:
  - `getConfigurations()` / `createConfiguration()`
  - `triggerAnalysis(configId)`
  - `getAnalysisJobs(journalId: ...)` / `getJobMetrics(jobId)`
  - `getStyleProfiles()` / `getStyleProfileByJournal(journalId)`
- Theme & Design Tokens:
  - `AppColors.primary`, `AppColors.surface`, `AppColors.surfaceSoft`, `AppColors.border`, `AppColors.textMuted`
  - Font: `Manrope`

---

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-09-26 02:07  
**Phase in progress:** All 4 phases completed  
**Status:** All deliverables implemented and verified with 0 analyzer issues

### Decisions made this session
- Created modular `JournalCommandCenterPanel` widget in `lib/features/admin/presentation/widgets/journal_command_center_panel.dart`.
- Refactored `JournalsView` into responsive Master-Detail (40% Left Catalog / 60% Right Command Center).
- Enabled 1-touch execution preset: auto-detects/creates journal configuration (300 articles, 2022-2024, auto-domain) and launches analysis in a single background sequence with zero required form fields.
- Implemented live 4-stage pipeline stepper (OpenAlex ➔ GROBID/MinIO ➔ Normalizer ➔ NLP Engine) with 2-second background timer polling.
- Rendered instant NLP Style Profile overview upon completion (Sentence Lengths, Hyland Stance, CARS Rhetorical Moves).

### Next immediate action
Provide demo and walkthrough report to user.

