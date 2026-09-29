# Plan: Journal Style Profile Side-by-Side Comparison & Radar Chart

**Date:** 2026-09-26  
**Mode:** --fast  
Risk: normal — Frontend UI component & custom painter enhancement; zero backend schema or auth changes.

---

## Architecture Overview

```text
┌────────────────────────────────────────────────────────────────────────┐
│ ProfilesReviewView (Header: View Mode Toggle)                          │
│   [ Chi tiết đơn lẻ ]  <----->  [ So sánh tạp chí (2-3) ]              │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ Comparison Control Bar: Multi-Select Journal Chips                     │
│   [✓] IEEE TSE (Blue)  [✓] PLOS ONE (Purple)  [ ] Nature Sci (Amber)  │
└──────────────────────────────────┬─────────────────────────────────────┘
                                   │
        ┌──────────────────────────┴──────────────────────────┐
        │                                                     │
        ▼                                                     ▼
┌───────────────────────────────────────┐ ┌───────────────────────────────────────┐
│ StyleRadarChart (CustomPainter)       │ │ Dynamic Highlights & Insight Summary  │
│ - 6 Normalized Style Axes             │ │ - Key divergences in Hedging, Stance, │
│ - Concentric grid rings & radar paths │ │   Sentence length, and CARS Moves     │
│ - Semi-transparent polygon series     │ │ - High-contrast callout chips         │
└───────────────────────────────────────┘ └───────────────────────────────────────┘
                                   │
                                   ▼
┌────────────────────────────────────────────────────────────────────────┐
│ Side-by-Side Journal Comparison Cards (2–3 Columns)                    │
│ - Colored Accent Header per Journal                                    │
│ - Detailed Metrics: Length (P10/P50/P90), Lexical Density, Hedges, etc.│
│ - Stance Distribution & CARS rhetorical moves breakdown                │
│ - Authentic Intro Exemplar sentence with DOI quote card                │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Phases Overview

| Phase | Filename | Objective | Key Deliverables | Status |
| :--- | :--- | :--- | :--- | :--- |
| **01** | `phase-01-radar-chart-painter.md` | Multi-Series Radar Chart Component | Create `StyleRadarChart` in `lib/features/admin/presentation/widgets/style_radar_chart.dart` using Flutter `CustomPainter` with 6 normalized axes, polygon layering, vertex dots, and legend | `[x] Completed` |
| **02** | `phase-02-comparison-view-integration.md` | Comparison Mode & Side-by-Side Layout | Integrate view switcher in `ProfilesReviewView`, chip selector (2–3 journals), radar chart container, and side-by-side metric comparison cards | `[x] Completed` |
| **03** | `phase-03-responsive-and-verification.md` | Responsive Polish & QA Verification | Verify layout responsiveness on narrow and desktop viewports, run `flutter analyze`, and confirm smooth 60fps rendering | `[x] Completed` |

---

## Dependencies & Environment

- Target Framework: Flutter 3.x (Web / Desktop)
- State Management: StatefulWidget / setState (local to `ProfilesReviewView`)
- Chart Engine: Pure Flutter `CustomPainter` (zero extra dependencies)
- Verification: `flutter analyze`

---

## Session Notes
<!-- Updated by cook automatically — do not edit manually -->

**Last active:** 2026-09-26 12:32  
**Phase in progress:** All phases completed  
**Status:** All 3 phases implemented and verified. flutter analyze 0 issues found. Hot reload ready.
