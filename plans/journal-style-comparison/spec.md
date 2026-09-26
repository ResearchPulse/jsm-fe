# Spec: Journal Style Profile Side-by-Side Comparison & Radar Chart

**Date:** 2026-09-26  
**Status:** Ready for Planning  
**Target Module:** `jsm-fe` (Flutter Admin - Profiles Review View) & `jsm-be` (Existing Style Profiles API)

---

## 1. Problem Statement

Researchers and authors seeking to publish scientific papers need to understand how target journals differ in writing style (e.g. sentence conciseness, use of hedges vs boosters, argument stance, and rhetorical move completeness). Currently, `ProfilesReviewView` only allows viewing one journal's profile in isolation, making it impossible to directly compare writing conventions across competing journals.

This spec defines a **Side-by-Side Journal Comparison Mode** with an interactive **6-Axis Radar Chart** built directly into `ProfilesReviewView`, enabling researchers to select 2 to 3 journals and instantly compare their stylistic fingerprints.

---

## 2. User Stories

- **[P1] As a researcher/admin, I want to switch between "Xem đơn lẻ" and "So sánh tạp chí" mode** so that I can easily toggle between deep inspection of one journal and comparison across multiple journals.
  - *Acceptance Criteria:* A segmented toggle button `[ Chi tiết ] | [ So sánh (2-3) ]` is displayed on the header; clicking it changes view mode without re-fetching API data.

- **[P1] As a user, I want to pick 2 or 3 journals from a multi-select chip bar to compare** so that I can choose the exact journals I am considering submitting to.
  - *Acceptance Criteria:* 
    - The top toolbar displays journal chips with checkboxes.
    - Each selected journal is assigned a distinct color (Journal 1: Blue `#2563EB`, Journal 2: Purple `#8B5CF6`, Journal 3: Amber `#D97706`).
    - Minimum 2 journals, maximum 3 journals can be selected simultaneously. If 3 are already selected, selecting another prompts the user or disables further selection.

- **[P1] As a user, I want to see a Multi-Series Radar Chart comparing the journals across 6 standardized style axes** so that I can visualize multidimensional style differences at a single glance.
  - *Acceptance Criteria:*
    - 6 axes normalized 0–100%:
      1. Độ dài câu (Sentence Length)
      2. Mật độ từ vựng (Lexical Density)
      3. Mức độ rào đón (Hedging Intensity)
      4. Mức độ khẳng định (Booster Intensity)
      5. Tính trung lập lập luận (Neutral Stance)
      6. Cấu trúc CARS (CARS Move Completeness)
    - Each journal is plotted as a semi-transparent polygon with a solid colored outline and vertices.
    - Legend displays journal names with their color swatches.
    - Implemented with Flutter `CustomPainter` with 0 external dependencies.

- **[P1] As a user, I want a Side-by-Side comparison table/cards showing the exact metrics and exemplar sentences for each selected journal** so that I can inspect the concrete numbers and text examples.
  - *Acceptance Criteria:*
    - 2–3 side-by-side columns matching the selected journals.
    - Rows compare: Mean Sentence Length (P10/P50/P90), Lexical Density, Hedges per 1k words, Boosters per 1k words, Stance breakdown (% Neutral, % Support, % Contradict), and Intro Exemplar sentence.

- **[P2] As a user, I want a "Key Takeaways / Highlights" summary card** that automatically describes the most notable difference between the selected journals (e.g. "Journal A uses 35% more hedging than Journal B").
  - *Acceptance Criteria:* A prominent card highlights the primary stylistic divergence calculated from the metrics.

---

## 3. Functional Requirements

### FR-01: View Mode Toggle & State Management
- In `_ProfilesReviewViewState`, maintain:
  - `bool _isCompareMode = false;`
  - `List<String> _selectedCompareIds = [];`
- Initial selection: if `_profiles` contains $\ge 2$ items, pre-select the first 2 journals for comparison.

### FR-02: Multi-Series Radar Chart (`StyleRadarChart`)
- A custom Flutter `CustomPainter` widget `StyleRadarPainter`:
  - Draws concentric hexagonal/polygon grid rings (20%, 40%, 60%, 80%, 100%).
  - Draws 6 radial axis lines from center to outer ring.
  - Labels the 6 axes with clean typography.
  - For each selected profile:
    - Normalizes the 6 metrics to a scale of `0.0` to `1.0`:
      - `norm_len = ((mean_len - 15) / 20).clamp(0.0, 1.0)`
      - `norm_lex = ((lex_density - 0.35) / 0.35).clamp(0.0, 1.0)`
      - `norm_hedge = (hedges_per_1k / 40.0).clamp(0.0, 1.0)`
      - `norm_booster = (boosters_per_1k / 30.0).clamp(0.0, 1.0)`
      - `norm_stance = neutral_pct.clamp(0.0, 1.0)`
      - `norm_cars = ((m1 + m2 + m3) / 3.0).clamp(0.0, 1.0)`
    - Draws polygon with fill color `color.withAlpha(50)` and border `color.withAlpha(220)` with stroke width 2.5.
    - Draws small vertex circles at each axis point.

### FR-03: Side-by-Side Comparison Cards
- Renders an `IntrinsicHeight` or `Row` with 2–3 `Expanded` cards.
- Each card has a colored top accent bar matching the radar chart series.
- Displays:
  - Journal Title & ISSN
  - Analyzed Paper Count
  - Sentence length breakdown (Mean, P10, P50, P90)
  - Hedges vs Boosters ratio
  - Stance distribution bar
  - Intro exemplar quote with copy button

---

## 4. Non-Functional Requirements

- **Zero Extra Dependencies:** Pure Flutter `CustomPainter`, keeping app bundle small and fast.
- **Responsive Layout:** On desktop/tablet, side-by-side columns render horizontally; if window is narrowed (< 800px), gracefully stacks or scrolls horizontally.
- **Zero API Overload:** Uses the existing `/api/v1/journals/style-profiles` response already loaded in memory.

---

## 5. Success Metrics

1. User can switch to comparison mode and view 2–3 journals in $\le 1$ click.
2. Radar chart renders smoothly without stuttering (60 fps).
3. Exact differences in style (sentence length, hedging, CARS moves) are clearly visible side-by-side.
