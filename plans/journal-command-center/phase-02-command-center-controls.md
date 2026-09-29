# Phase 02: 1-Touch Preset Execution & Advanced Overrides

**Phase ID:** `phase-02-command-center-controls`  
**Parent Plan:** [`plan.md`](file:///e:/jsm/jsm-fe/plans/journal-command-center/plan.md)  
**Spec Reference:** [`spec.md`](file:///e:/jsm/jsm-fe/plans/journal-command-center/spec.md) (FR-02)  
**Priority:** P1

---

## Objective

Deliver the **zero-friction 1-touch execution** experience in the right panel:
- A prominent primary CTA button `[ ▶ Bắt đầu Khai phá & Phân tích ]`.
- Automatic detection and creation of `JournalConfiguration` (target 300 articles, 2022–2024, auto-domain) if absent.
- Triggering `triggerAnalysis` in a single asynchronous call.
- Optional collapsible accordion for advanced overrides (custom target article count, custom years).

---

## Tasks

1. **Selected Journal Header & Metadata Card:**
   - Display Title, ISSN-L, Publisher, Domain, Total Works from OpenAlex.
   - Status Badge (`Chưa cấu hình`, `Sẵn sàng`, `Đang chạy`, `Đã có hồ sơ`).

2. **1-Touch Primary Action:**
   - Button: `[ ▶ Bắt đầu Khai phá & Phân tích ]` (or `[ ▶ Khai phá lại ]` if completed).
   - On pressed:
     - If no configuration exists: call `_apiClient.createConfiguration(journalId: ..., domain: ..., targetArticles: 300, yearFrom: 2022, yearTo: 2024)`.
     - Call `_apiClient.triggerAnalysis(configId)`.
     - Notify user via toast / banner and immediately start tracking progress.

3. **Collapsible Advanced Customization:**
   - An accordion with `ExpansionTile` or toggle: `⚙ Tùy chỉnh nâng cao`.
   - Default is collapsed to preserve minimal aesthetic.
   - When opened: provides sliders or text inputs for `targetArticles` (default 300) and `yearFrom`..`yearTo`.

---

## Verification & Acceptance Criteria

- Clicking `[ Bắt đầu Khai phá & Phân tích ]` on an unconfigured journal creates the config and triggers the job in 1 single tap.
- No form validation error pops up during default preset execution.
- `flutter analyze` passes cleanly.
