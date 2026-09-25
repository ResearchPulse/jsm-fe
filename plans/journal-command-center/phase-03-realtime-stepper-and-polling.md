# Phase 03: Real-Time 4-Stage Stepper & Live Polling

**Phase ID:** `phase-03-realtime-stepper-and-polling`  
**Parent Plan:** [`plan.md`](file:///e:/jsm/jsm-fe/plans/journal-command-center/plan.md)  
**Spec Reference:** [`spec.md`](file:///e:/jsm/jsm-fe/plans/journal-command-center/spec.md) (FR-03)  
**Priority:** P1

---

## Objective

Build the interactive real-time pipeline status tracker inside the Command Center:
- 4 stages: `1. OpenAlex Harvester` ➔ `2. GROBID/MinIO Fetcher` ➔ `3. Normalizer` ➔ `4. NLP Engine`.
- Auto-polling job metrics every 2 seconds when status is `PENDING` or `RUNNING`.
- Animated progress bar and live counters (`Đã chuẩn hóa: X / 300 bài`).

---

## Tasks

1. **Pipeline Stepper Widget:**
   - 4 horizontal or vertical stage chips with dynamic icons:
     - `Pending`: Grey outline with clock icon.
     - `Running`: Animated rotating spinner with `AppColors.primary`.
     - `Completed`: Solid green check circle.
     - `Failed`: Red warning icon with error tooltip.

2. **Metrics & Progress Display:**
   - Smooth `LinearProgressIndicator` bound to `job['progress']` (0.0 to 100.0%).
   - Live metrics summary row:
     - `Harvested`: e.g. 300
     - `Fetched & Raw XML`: e.g. 298
     - `Normalized`: e.g. 296
     - `Thất bại`: e.g. 2 (with retry button)

3. **Background Timer Polling:**
   - `Timer.periodic(const Duration(seconds: 2), ...)` active only while job is running.
   - Automatically cancel timer on dispose or when job transitions to `COMPLETED` or `FAILED`.
   - On `COMPLETED`: Trigger refresh of Style Profile data.

---

## Verification & Acceptance Criteria

- Stepper dynamically shifts from Harvester to Fetcher to Normalizer as job progresses.
- Counter numbers update in real-time without flickering.
- Polling halts immediately once completed.
- `flutter analyze` passes cleanly.
