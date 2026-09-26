# Brainstorm: Radar Chart Point Hover Tooltip (Interactive Style Inspection)

**Date:** 2026-09-26

## Ideas Explored
1. **Direct Canvas Tooltip vs Flutter Widget Overlay:**
   - *Direct Canvas Drawing:* Fast, but tedious text layout, manual border-radii, potential text clipping.
   - *Flutter Stack + Positioned Floating Widget:* Crisper typography, native box shadows, smooth animations, auto-wrapping, easily styled with AppColors. (Selected direction).
2. **Tooltip Content Scope:**
   - *Multi-journal comparison summary on axis:* Shows all journals for that axis at once. (Dismissed based on user preference).
   - *Specific single-journal data at hovered point:* Shows journal name, axis title, raw unit value (e.g. 22.2 từ, 65%), and normalized percentage. (User's chosen direction).
3. **Cursor Interaction & Hit Detection:**
   - Hit threshold radius of ~16–18px around each vertex dot so users can effortlessly hover without pixel-hunting.
   - Nearest vertex resolution if multiple journals have very similar values on the same axis.
   - Interactive vertex enlargement (radius 4.5px → 7px + color aura) for tactile feedback.

## User's Direction
- **Targeted Single-Point Data:** When hovering over a point, display the exact metrics of that specific journal at that specific axis (e.g., `PLOS ONE: 22.2 từ/câu (74%)`).
- **Floating Badge:** The tooltip is a floating badge that dynamically tracks the cursor position smoothly with boundary-aware clamping.

## Open Questions
- None blocking. All data points (`rawDisplayValues`, `values`, `axisTitles`, `name`, `color`) are already pre-computed in `RadarDataset`.

## Risks
- **Boundary Clipping:** Cursor hovering near the top, bottom, or side edges could push the floating badge out of the card. *Mitigation:* Apply offset clamping (flip tooltip above/below or left/right depending on mouse position relative to canvas size).
