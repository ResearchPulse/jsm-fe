# Phase 02: Comparison Mode & Side-by-Side Layout

**File:** `phase-02-comparison-view-integration.md`  
**Stories Covered:** P1, P2 (Spec FR-01, FR-03)  
**Priority:** P1  

---

## 1. Objective
Update `ProfilesReviewView` in `lib/features/admin/presentation/views/profiles_review_view.dart` to support switching between the traditional single-journal inspector and a new Side-by-Side Comparison Mode comparing 2–3 selected journals.

---

## 2. File Modifications

### `lib/features/admin/presentation/views/profiles_review_view.dart`
- **State Additions**:
  - `bool _isCompareMode = false;`
  - `List<String> _selectedCompareIds = [];`
  - Pre-populate `_selectedCompareIds` with the first 2 available journals when data loads.
- **Top Header Toggle**:
  - Add segmented control: `[ Chi tiết đơn lẻ ]` vs `[ So sánh đối chiếu (2-3) ]`.
- **Comparison Toolbar (When in compare mode)**:
  - Horizontal list of selectable journal chips with checkbox and color badges (Blue `#2563EB`, Purple `#8B5CF6`, Amber `#D97706`).
  - Enforce constraint: min 2, max 3 journals. Disallow unchecking if only 2 remain; disallow checking if 3 already selected.
- **Comparison View Body**:
  - **Upper Section**:
    - Left (60%): `StyleRadarChart` rendering the 2–3 datasets.
    - Right (40%): "Điểm nhấn phong cách (Key Takeaways)" summary card highlighting the most prominent divergences (e.g. difference in hedging or sentence length).
  - **Lower Section**:
    - Side-by-Side comparison cards (2 or 3 columns in a responsive row).
    - Top colored accent bar matching the journal's radar series.
    - Full metric breakdown:
      - Thống kê câu: Mean length, P10, P50, P90.
      - Mật độ từ vựng & Rào đón/Khẳng định: Hedges per 1k, Boosters per 1k, Lexical density.
      - Phân bố lập luận (Stance): Thanh tỷ lệ phân đoạn màu (Neutral / Support / Contradict).
      - CARS Moves: Territory, Niche, Occupying bars.
      - Câu văn mẫu (Intro Exemplar) with DOI link and copy action.

---

## 3. Verification Criteria
- Seamless switching between single mode and compare mode without network refetch.
- Selecting different journals dynamically updates the radar chart and side-by-side cards.
- Layout remains visually clean and functional with both 2 and 3 journals.
