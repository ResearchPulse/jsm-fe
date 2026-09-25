# Phase 04: Instant NLP Style Profile Overview

**Phase ID:** `phase-04-nlp-style-profile-card`  
**Parent Plan:** [`plan.md`](file:///e:/jsm/jsm-fe/plans/journal-command-center/plan.md)  
**Spec Reference:** [`spec.md`](file:///e:/jsm/jsm-fe/plans/journal-command-center/spec.md) (FR-04)  
**Priority:** P1

---

## Objective

Deliver the final handoff experience to Member 3's NLP output directly inside the Command Center:
- Once a journal's pipeline job completes, automatically fetch its Style Profile (`/api/v1/admin/style-profiles/journal/{id}`).
- Render a rich summary card containing:
  - **Sentence Length Distribution:** Mean, P10, P50 (median), P90.
  - **Hyland Stance Metrics:** Frequency per 1,000 words for Hedges, Boosters, and Reporting Verbs.
  - **Voice & Person:** Percentage of Passive vs. Active voice, We-subject frequency.
  - Direct navigation button to full Profiles view (`onNavigateToTab(5)`).

---

## Tasks

1. **Profile Data Fetching:**
   - Call `_apiClient.getStyleProfileByJournal(journalId)`.
   - If profile exists, display the "Hồ Sơ Phong Cách Khai Phá" card.
   - If not yet generated, provide a 1-click button `[ Tạo Hồ Sơ Phong Cách Ngay ]` that triggers `POST /api/v1/nlp/build-profile`.

2. **Metrics Grid UI:**
   - 3 sub-cards in a clean grid:
     1. **Độ dài câu (Sentence Length):** Median, Mean, Max.
     2. **Lập trường học thuật (Hyland Stance):** Hedges (cẩn trọng), Boosters (khẳng định).
     3. **Thể câu & Ngôi xưng (Voice & Person):** Tỷ lệ bị động (Passive %), We-subject.

3. **CTA Navigation:**
   - Outlined Button: `[ Xem chi tiết & Đối chuẩn Corpus ➔ ]` navigating directly to Tab 5 (Profiles Review).

---

## Verification & Acceptance Criteria

- Completed journals render the Style Profile summary without requiring page reload.
- The metrics accurately reflect the values returned by Member 3's NLP backend.
- `flutter analyze` passes cleanly with 0 errors.
