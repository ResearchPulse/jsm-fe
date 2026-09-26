# Phase 01: Multi-Series Radar Chart Component

**File:** `phase-01-radar-chart-painter.md`  
**Stories Covered:** P1 (Spec FR-02)  
**Priority:** P1  

---

## 1. Objective
Build an interactive, animated, dependency-free `StyleRadarChart` widget in `lib/features/admin/presentation/widgets/style_radar_chart.dart` using Flutter `CustomPainter`. It must render a 6-axis polygonal grid with multiple overlapping semi-transparent series representing the stylistic profiles of 2 to 3 journals.

---

## 2. File Modifications

### `lib/features/admin/presentation/widgets/style_radar_chart.dart` (New file)
- **Data Model**:
  - `class RadarDataset`:
    - `String name;`
    - `Color color;`
    - `List<double> values;` (normalized 0.0 to 1.0 for the 6 axes)
    - `List<String> rawDisplayValues;` (e.g. `["24.6 từ", "58%", "18.2/1k", "12.4/1k", "64%", "95%"]`)
- **6 Normalized Axes**:
  1. Độ dài câu (Sentence Length)
  2. Mật độ từ vựng (Lexical Density)
  3. Mức độ rào đón (Hedging)
  4. Mức độ khẳng định (Boosters)
  5. Tính trung lập lập luận (Neutral Stance)
  6. Khung lập luận CARS (CARS Completeness)
- **CustomPainter Implementation (`StyleRadarPainter`)**:
  - Draws 5 concentric polygon grid lines (20%, 40%, 60%, 80%, 100%) with subtle border colors (`AppColors.border`).
  - Draws 6 radial axis lines from center to outer vertices.
  - Draws text labels at the outer margin of each vertex.
  - For each dataset:
    - Calculates coordinates based on `value * radius` for each axis angle ($i \times \pi / 3 - \pi / 2$).
    - Fills closed polygon with `dataset.color.withAlpha(45)`.
    - Strokes polygon outline with `dataset.color` (strokeWidth: 2.5).
    - Draws circular vertex points (`radius: 4.5`) with white center and colored stroke.
- **Legend & Header**:
  - Renders a clean legend below or beside the radar chart with color dots, journal titles, and toggles.

---

## 3. Verification Criteria
- `StyleRadarChart` renders smoothly in any container.
- Polygon shapes accurately reflect normalized values.
- `flutter analyze` passes with 0 issues.
