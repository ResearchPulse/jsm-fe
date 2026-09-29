# Spec: Radar Chart Point Hover Tooltip

**Feature Slug:** `radar-hover-tooltip`  
**Target File:** `lib/features/admin/presentation/widgets/style_radar_chart.dart`

## 1. Overview & Objective
Enable desktop users to hover over any vertex point in the Radar Chart to immediately inspect detailed style metrics via a smooth, non-intrusive floating tooltip badge following the mouse cursor.

## 2. User Stories & Acceptance Criteria

### [P1] Vertex Hit Detection & Cursor Hovering
- **Given** a rendered Radar Chart with 1 to 3 journal datasets,
- **When** the user moves the mouse cursor within a 16px radius of any vertex dot,
- **Then**:
  1. The system identifies the hovered dataset and axis index.
  2. The vertex dot on the radar chart visually highlights (radius enlarges with subtle glow/ring in the journal's color).
  3. The mouse cursor changes to `SystemMouseCursors.click` or stays responsive.

### [P1] Floating Tooltip Badge Presentation
- **Given** an active hover over a vertex point,
- **Then** a floating badge appears tracking the cursor position (`Offset(x + 14, y - 28)` with boundaries clamped inside the chart area):
  - **Journal Dot & Name:** Circle colored with the journal's series color (`ds.color`) + bold journal name.
  - **Axis Metric Label:** Vietnamese axis title (e.g. "Độ dài câu") + English subtitle (e.g. "Sentence Length").
  - **Raw Value:** Large, legible formatted value (e.g. `22.2 từ`, `15.4/1k`, `78%`).
  - **Normalized Score:** Badge showing percentage score on radar axis (e.g. `74%`).

### [P2] Smooth Exit & Edge Clamping
- **When** the cursor moves outside the hit radius of all vertices,
  - The tooltip fades out / hides immediately with no lingering artifacts.
  - The vertex returns to its default size (radius 4.5px).
- **When** the cursor is near the top or right edge of the chart,
  - The tooltip dynamically flips to prevent overflowing or being cropped by container bounds.

## 3. Measurable Success Criteria
1. Hover detection response time < 16ms (60 FPS smooth rendering).
2. Hit test radius: 16px around each calculated vertex coordinate `(center.dx + r * cos, center.dy + r * sin)`.
3. Zero regressions in existing legend, axis labels, or polygon drawing.
4. `flutter analyze` reports 0 errors.
