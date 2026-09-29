# Spec: Admin UI Simplification & Real-Time Progress Experience

**Date:** 2026-09-26  
**Status:** Ready for Planning  
**Target Module:** `jsm-fe` (Flutter Admin Console)  
**Slug:** `admin-ui-simplification`

---

## 1. Problem Statement

Following the 3-core-tab consolidation, user testing revealed several UX friction points where internal backend mechanics are leaking into the presentation layer:
1. The left journal catalog in Tab 0 renders an unpaginated 16-item list, leading to excessive vertical scrolling.
2. The right Command Center displays a 4-box technical pipeline (`OpenAlex`, `GROBID / MinIO`, `Normalizer`, `NLP Engine`) with internal jargon that researchers do not care about. Furthermore, users cannot see which specific article is currently being processed.
3. The top `AdminHeader` retains an unnecessary "Kích hoạt phân tích" action button that duplicates the 1-touch button inside the selected journal card.
4. Tab 2 ("Hệ thống & Kỹ thuật") displays a cluttered 6-stage operational stepper and redundant action buttons, causing visual noise.

This spec defines a streamlined, user-first UI polish that removes technical bloat, adds compact catalog pagination, displays real-time article-level analysis progress, and declutters both the header and system tabs.

---

## 2. User Stories

- **[P1] As a Researcher, I want pagination on the left journal list** so that the catalog fits neatly on screen and I can browse journals 5–6 items at a time without endless scrolling.
  - *Acceptance Criteria:*
    - The left column renders at most 6 journals per page.
    - A clean footer displays `< Trang 1 / 3 >` with disabled states for previous/next arrows at boundaries.
    - Changing search query or filter tags resets page to 1.

- **[P1] As a Researcher, I want the technical pipeline replaced by a simple "Đang phân tích" card showing the exact article in progress** so that I can see live progress in human terms without technical jargon.
  - *Acceptance Criteria:*
    - The 4 technical boxes (`GROBID / MinIO / Normalizer / TEI XML`) are replaced with a minimalist card titled **"Đang phân tích"**.
    - Displays a smooth progress bar (e.g., `299 / 300 bài báo` – `99.6%`).
    - Displays the title of the article currently being processed (e.g., `Đang phân tích bài 245/300: "Deep Learning for Structural Bioinformatics..."`).
    - If analysis is finished, displays a calm summary state (e.g., `Đã hoàn tất phân tích 299/300 bài báo`).

- **[P1] As a user, I want the "Kích hoạt phân tích" button removed from the Header** so that the top bar remains clean and uncluttered.
  - *Acceptance Criteria:*
    - `AdminHeader` removes the blue `Kích hoạt phân tích` button.
    - Header contains only Breadcrumbs, Title, and Search bar.

- **[P1] As an Administrator, I want Tab 2 ("Hệ thống & Kỹ thuật") decluttered** so that I can monitor job status without obsolete 6-step diagrams or duplicate action buttons.
  - *Acceptance Criteria:*
    - Remove the 6-step `TIẾN TRÌNH KHAI PHÁ DỮ LIỆU ĐANG VẬN HÀNH` stepper container from `JobMonitorView`.
    - Remove the duplicate `Bắt đầu phân tích mới` button in `JobMonitorView`.
    - Retain clean job cards, status filters, logs view, and retry actions.
    - Ensure smooth switching between sub-tabs (`Nhật Ký Tác Vụ & Debug`, `Cài Đặt Dịch Vụ`, `Quản Lý Người Dùng`) with zero rendering errors.

---

## 3. Functional Requirements

### FR-01: Catalog Pagination in `JournalsView`
- Implement pagination state in `_JournalsViewState`: `int _currentPage = 1`, `static const int _pageSize = 6`.
- Slice the filtered journal list: `_paginatedJournals = _filteredJournals.skip((_currentPage - 1) * _pageSize).take(_pageSize).toList()`.
- Add a sleek pagination bar at the bottom of the left column with:
  - Total journal count: `Hiển thị ${(currentPage - 1)*pageSize + 1} - ... / ${total} tạp chí`.
  - Navigation controls: `[<] Trang 1 / 3 [>]`.

### FR-02: Real-time "Đang phân tích" Card in `JournalCommandCenterPanel`
- Replace `_buildPipelineStatusCard()` with `_buildActiveAnalysisCard()`.
- Section title: **"Đang phân tích"** (or **"Tiến độ phân tích"**).
- Linear progress bar with percentage and article counter.
- Active article ticker:
  - When status is running/mining: An animated or pulsing document indicator with `Đang phân tích bài ${currentArticleIndex}/${totalArticles}: "${currentArticleTitle}"`.
  - When status is completed: `Đã phân tích hoàn tất ${completedArticles}/${totalArticles} bài báo` + error badge with log link if any failed.

### FR-03: Header Decluttering
- Remove `ElevatedButton.icon(label: 'Kích hoạt phân tích')` from [AdminHeader](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/widgets/admin_header.dart).
- Remove `onNewJobPressed` parameter or make it optional with default null.

### FR-04: System & Debug Tab Clean-up
- In [JobMonitorView](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/views/job_monitor_view.dart):
  - Remove the 6-step stepper widget `TIẾN TRÌNH KHAI PHÁ DỮ LIỆU ĐANG VẬN HÀNH`.
  - Remove `Bắt đầu phân tích mới` button next to the refresh icon.
  - Keep the refresh icon, filter pills, and job items list.
- In [SystemAndDebugView](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/views/system_and_debug_view.dart):
  - Ensure all 3 sub-tabs mount and render flawlessly.

---

## 4. Non-Functional Requirements

- **Design Harmony:** Use `AppColors.surface`, `AppColors.borderSoft`, `AppColors.primary`, and `Manrope` typography.
- **Performance:** Pagination calculation is $O(1)$ client-side slice. Zero lag during page flips.
- **Cleanliness:** Remove all dead code and unused parameters cleanly.
- **Compilation:** 100% clean `flutter analyze` with 0 errors and 0 warnings.
