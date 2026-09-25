# Phase 01: Catalog Pagination & Header Clean-up

**File:** `phase-01-pagination-and-header-cleanup.md`  
**Stories Covered:** P1 (Spec FR-01, FR-03)  
**Priority:** P1  

---

## 1. Objective
1. Add responsive 6-item pagination to the left journal catalog in `JournalsView`, including footer controls (`< Trang 1 / 3 >`) and automatic reset to page 1 upon search query or filter tag change.
2. Remove the redundant `Kích hoạt phân tích` button from `AdminHeader` so the header focuses exclusively on Breadcrumb, Title, and Search.

---

## 2. File Modifications

### `lib/features/admin/presentation/views/journals_view.dart`
- Add pagination state to `_JournalsViewState`:
  - `int _currentPage = 1;`
  - `static const int _pageSize = 6;`
- In `_loadJournals()`, `_onSearchChanged()`, and `_onFilterTagChanged()`:
  - Reset `_currentPage = 1;`
- Derive paginated list:
  ```dart
  final totalPages = (_filteredJournals.isEmpty) ? 1 : (_filteredJournals.length / _pageSize).ceil();
  final startIndex = (_currentPage - 1) * _pageSize;
  final paginatedList = _filteredJournals.skip(startIndex).take(_pageSize).toList();
  ```
- In left column build:
  - Render `paginatedList` instead of `_filteredJournals`.
  - Add footer pagination bar below the ListView:
    - Text: `Hiển thị ${startIndex + 1} - ${min(startIndex + _pageSize, _filteredJournals.length)} / ${_filteredJournals.length} tạp chí`
    - Buttons: Previous `<` (disabled when `_currentPage <= 1`) and Next `>` (disabled when `_currentPage >= totalPages`).
    - Current page badge: `Trang $_currentPage / $totalPages`.

### `lib/features/admin/presentation/widgets/admin_header.dart`
- Remove the `ElevatedButton.icon(onPressed: onNewJobPressed, label: Text('Kích hoạt phân tích'))`.
- Make `onNewJobPressed` optional or remove call sites if unused.

---

## 3. Verification Criteria
- `flutter analyze` passes with 0 errors and 0 warnings.
- Changing search filters resets pagination to page 1.
- Header no longer has the blue "Kích hoạt phân tích" button.
