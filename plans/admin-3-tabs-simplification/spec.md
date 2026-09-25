# Spec: Admin Navigation Simplification (3-Tab Core Architecture)

**Date:** 2026-09-26  
**Status:** Ready for Planning  
**Target Module:** `jsm-fe` (Flutter Admin Console)

---

## 1. Problem Statement

Following the successful implementation of the **Journal All-in-One Command Center**, the daily workflow of mining, GROBID/MinIO extraction, progress monitoring, and quick Style Profile review is now unified in a single responsive screen.

However, the sidebar navigation still exposes 7–8 fragmented menu items (`Tổng quan`, `Danh mục`, `Cấu hình`, `Giám sát tác vụ`, `Kho Snapshots`, `Hồ sơ phong cách`, `Cài đặt`, `Người dùng`). This creates unnecessary visual clutter, redundant tabs, and cognitive friction for researchers.

This spec defines the consolidation of the Admin Console into **3 Core Focused Tabs** organized by functional domain, adopting a minimalist, zero-clutter layout.

---

## 2. User Stories

<!-- P1 = MVP (must ship), P2 = high value, P3 = future enhancement -->

- **[P1] As a Researcher / Admin, I want the sidebar to contain exactly 3 clear tabs** so that I can focus entirely on research and data pipeline tasks without navigational noise.
  - *Acceptance Criteria:* Sidebar navigation renders exactly 3 items:
    1. `Trung tâm Tạp chí` (Khai phá & Pipeline)
    2. `Hồ sơ & Đối chuẩn NLP` (Học thuật & Corpus)
    3. `Hệ thống & Kỹ thuật` (Giám sát & Cài đặt)

- **[P1] As a user, I want the app to open directly into "Trung tâm Tạp chí" upon launch** so that I can immediately start or monitor journal mining without having to click past an empty landing page.
  - *Acceptance Criteria:* Default `_selectedIndex` in `AdminDashboardPage` is set to 0 (`Trung tâm Tạp chí`).

- **[P1] As Member 3 / NLP Researcher, I want Tab 1 ("Hồ sơ & Đối chuẩn NLP") to unite deep Style Profiles and Corpus Snapshots** via a sleek top sub-tab switcher so that I can inspect exemplar sentences, check CARS rhetorical moves, compare journals against the Reference Corpus, and export datasets in one place.
  - *Acceptance Criteria:* Tab 1 features a modern segmented tab bar toggling between:
    - *Phân mục 1:* Hồ sơ phong cách & Rhetorical Moves (`ProfilesReviewView`)
    - *Phân mục 2:* Kho bài & Corpus Snapshots (`SnapshotsView`)

- **[P1] As an Engineer / Admin, I want Tab 2 ("Hệ thống & Kỹ thuật") to consolidate debugging and infrastructure controls** so that Job logs, article retry actions, service endpoints (MinIO, GROBID, Redis), and user credentials are safe in a dedicated technical area.
  - *Acceptance Criteria:* Tab 2 features a segmented tab bar toggling between:
    - *Phân mục 1:* Nhật ký tác vụ & Debug (`JobMonitorView`)
    - *Phân mục 2:* Cài đặt kết nối & Người dùng (`SettingsView` & `UsersView`)

- **[P2] As a user, I want all deep links and buttons (e.g., "Xem toàn diện & Đối chuẩn Corpus ➔" or "Xem chi tiết logs ➔") to route directly to their corresponding sub-tab** so that contextual workflows remain 100% seamless.
  - *Acceptance Criteria:* `onNavigateToTab(1)` opens Tab 1 (Style Profiles), while `onNavigateToTab(2)` opens Tab 2 (Job Logs).

---

## 3. Functional Requirements

### FR-01: Redesign `AdminSidebar` to 3 Core Items
- Remove obsolete section headers and consolidate all navigation into 3 clean items:
  1. Index 0: `Icons.auto_stories_rounded` — **Trung tâm Tạp chí**
  2. Index 1: `Icons.psychology_rounded` — **Hồ sơ & Đối chuẩn NLP**
  3. Index 2: `Icons.tune_rounded` — **Hệ thống & Kỹ thuật**

### FR-02: Set Default Initial View
- Initialize `_selectedIndex = 0` in `AdminDashboardPage` to immediately load `JournalsView` with its Master-Detail Command Center.

### FR-03: Consolidated Tab 1 View (`StyleAndCorpusView`)
- Create a composite view with a clean top segmented switcher (`Hồ sơ phong cách học thuật` vs. `Kho Corpus Snapshots`).
- Preserve all existing state, search filters, and API interactions from `ProfilesReviewView` and `SnapshotsView`.

### FR-04: Consolidated Tab 2 View (`SystemAndDebugView`)
- Create a composite view with a top segmented switcher (`Nhật ký tác vụ & Logs` vs. `Cài đặt kết nối & Người dùng`).
- Preserve all retry, cancellation, and config update capabilities.

### FR-05: Update Deep Navigation Routing
- Update `widget.onNavigateToTab(...)` in `JournalCommandCenterPanel`, `JournalsView`, `OverviewView`, and `AdminHeader` to map cleanly to the 3-tab indices:
  - Tab 0: Journals Command Center
  - Tab 1: Style Profiles & Corpus Analytics
  - Tab 2: System Monitor & Settings

---

## 4. Non-Functional Requirements

- **Visual Minimalism:** Adhere to `AppColors` tokens, generous padding (`padding: 24-32px`), clean borders (`AppColors.borderSoft`).
- **Zero Regression:** No existing functionality (API calls, retry buttons, snapshot downloads) is lost or compromised.
- **Fast Tab Switching:** Instant sub-tab switching using `IndexedStack` or clean stateful switching (< 16ms frame render).

---

## 5. Success Criteria

- [ ] Sidebar displays exactly 3 top-level items with zero unnecessary clutter.
- [ ] App launches directly into "Trung tâm Tạp chí" as the home view.
- [ ] Users can access detailed NLP Style Profiles and Corpus Snapshots in Tab 1 via a segmented header.
- [ ] Users can debug jobs, retry failed articles, and manage service settings in Tab 2.
- [ ] Deep links from the Command Center route accurately to their target sub-views.
- [ ] `flutter analyze` passes cleanly with 0 errors and 0 warnings.
