# Spec: Journal All-in-One Command Center (Zero-Friction Pipeline & NLP UI)

**Date:** 2026-09-26  
**Status:** Ready for Planning  
**Target Module:** `jsm-fe` (Flutter Admin Console) & `jsm-be` (FastAPI Endpoints Integration)

---

## 1. Problem Statement

Mining and analyzing academic journals currently requires navigating between multiple disjointed screens (`JournalsView` ➔ `ConfigurationsView` ➔ `JobMonitorView` ➔ `ProfilesReviewView`). Users must perform redundant clicks, type manual form fields (year range, article counts), and track asynchronous pipeline jobs across different pages without immediate visibility into the resulting NLP Style Profiles.

This spec defines an **All-in-One Journal Command Center** integrated directly inside the Journal catalog, enabling a **1-click execution experience** from Journal selection to NLP profile visualization.

---

## 2. User Stories

<!-- P1 = MVP (must ship), P2 = high value, P3 = future enhancement -->

- **[P1] As an Admin / Researcher, I want to select any journal in `JournalsView` and immediately see a Command Center panel on the right side** so that I can manage, trigger, and inspect the journal without leaving the page.
  - *Acceptance Criteria:* Clicking any journal card/row highlights it as active and opens the responsive Command Center on the right (60–65% width on desktop).

- **[P1] As a user, I want a single "1-Touch Preset" action (`[ Bắt đầu Khai phá & Phân tích ]`)** that automatically uses optimal defaults (300 articles, 3 most recent years, Gold OA priority) without forcing me to fill out forms.
  - *Acceptance Criteria:* Clicking the primary action button triggers configuration creation (if not exists) and analysis job creation in a single background sequence with zero required input fields.

- **[P1] As a user, I want to watch the real-time 4-stage pipeline stepper (`OpenAlex Harvester ➔ Grobid/MinIO Fetcher ➔ Parser/Normalizer ➔ NLP Engine`) inside the Command Center** so that I can see the progress of articles and sentences being extracted in live time.
  - *Acceptance Criteria:* The panel shows an animated stepper with live article counters, percentage bar, and status indicators without navigating to `JobMonitorView`.

- **[P1] As a user, I want the Command Center to automatically transition to a "Style Profile Summary" upon pipeline completion** so that I immediately see the journal's writing style profile (sentence length distribution, passive/active voice, Hyland stance frequencies).
  - *Acceptance Criteria:* When job reaches `COMPLETED`, the right panel switches to show a rich summary card with key NLP metrics and a button to view the full profile.

- **[P2] As an advanced user, I want an optional expandable "Tùy chỉnh cấu hình" (Advanced Customization) toggle** so that I can override the target article count (e.g. 50, 100, 300) or year range if desired.
  - *Acceptance Criteria:* An accordion/toggle cleanly unfolds target and year inputs, keeping default collapsed for clean minimalism.

- **[P2] As a user, I want quick filters for Domain and Configuration Status in the journal list** so that I can quickly pick an unconfigured journal in my desired field.
  - *Acceptance Criteria:* Status chips (`Tất cả`, `Đã cấu hình`, `Chưa cấu hình`) and domain dropdown filter the list instantaneously.

- **[P3] As a user, I want an interactive radar chart comparing the journal's Style Profile directly against the Reference Corpus** inside the Command Center.
  - *Acceptance Criteria:* Visual radar/bar charts rendering lexical metrics (Hedges, Boosters, Reporting Verbs) side-by-side.

---

## 3. Functional Requirements

### FR-01: Responsive Master-Detail Layout in `JournalsView`
- Screen splits into:
  - **Left Panel (35–40% width):** Journal Catalog (Search, Domain filter, Status filter, Journal cards/tiles).
  - **Right Panel (60–65% width):** Dynamic Journal Command Center.
- If no journal is selected, the right panel displays a helpful empty state ("Chọn một tạp chí từ danh sách bên trái để bắt đầu khai phá dữ liệu hoặc xem hồ sơ phong cách").

### FR-02: 1-Touch Smart Preset Execution
- Primary CTA Button: `[ ▶ Bắt đầu Khai phá & Phân tích ]`.
- Default presets applied seamlessly:
  - `target_articles`: 300 articles.
  - `year_from`: `DateTime.now().year - 3` (e.g., 2022).
  - `year_to`: `DateTime.now().year - 1` (e.g., 2024).
  - `domain`: Journal's detected field from OpenAlex / database.
- One-click trigger sequence:
  1. Checks if `JournalConfiguration` exists for `journal_id`. If not, calls `POST /api/v1/journals/{id}/config`.
  2. Calls `POST /api/v1/journals/{id}/jobs` to launch the pipeline job.
  3. Transitions UI state to `RUNNING` and polls job status every 2 seconds.

### FR-03: Real-Time Pipeline Progress Tracker
- Interactive 4-Stage Stepper:
  1. **Thu thập Metadata (OpenAlex Harvester)**
  2. **Tải Toàn văn & GROBID (MinIO Raw XML)**
  3. **Làm sạch & Tách câu (Normalizer ~30.000 câu)**
  4. **Phân tích Phong cách NLP & AI (Member 3 Engine)**
- Displays:
  - Overall progress bar (`LinearProgressIndicator` with percentage).
  - Counter badge: `Đã chuẩn hóa: X / Y bài`.
  - Error badge with 1-click retry if failed.

### FR-04: Instant Style Profile Overview on Completion
- Once job reaches `COMPLETED`, fetches and renders:
  - **KPI Metrics:** Total normalized articles, Total sentences extracted, Average sentence length.
  - **Hyland Stance Breakdown:** Frequency of Hedges (từ cẩn trọng), Boosters (từ khẳng định), Reporting Verbs (động từ trích dẫn).
  - **Voice & Person:** Tỷ lệ thể bị động (Passive) vs. chủ động (Active), We-subject frequency.
  - Quick action: `[ Xem chi tiết toàn diện trong Profiles ]`.

---

## 4. Non-Functional Requirements

- **Zero-Friction UX:** From opening the app to triggering analysis requires $\le 2$ clicks.
- **Performance:** Smooth transitions without blocking the main UI thread during polling (< 16ms frame render).
- **Design Consistency:** Strict adherence to `AppColors` tokens, `Manrope` typography, rounded card styles (`borderRadius: 12-16px`).
- **Resilience:** Graceful error handling with offline/network retry notifications (`SnackBar` or inline banner).

---

## 5. Success Criteria

- [ ] Selecting a journal in `JournalsView` opens the Command Center in the right pane without page reload.
- [ ] Users can trigger a complete 300-article mining pipeline with exactly **1 click**.
- [ ] Live pipeline stage and progress percent update in real-time.
- [ ] Upon pipeline completion, NLP style metrics appear directly in the Command Center.
- [ ] `flutter analyze` passes cleanly with 0 errors.

---

## 6. Out of Scope

- Modifying core NLP algorithm logic in backend (Member 3 API contracts remain as-is).
- Mobile single-column bottom sheet layout (desktop/web window is primary target for admin).
