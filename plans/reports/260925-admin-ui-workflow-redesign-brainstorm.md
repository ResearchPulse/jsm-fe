# Brainstorm: Admin Console Workflow & Pipeline UI Redesign

**Date:** 2026-09-25

## Ideas Explored

1. **Direction 1: Classic Modern SaaS Console (Stripe / Vercel style)**
   - Standard data-table-first layout across all views, generic 4-stat KPI header, traditional sidebar grouping (Data, Operations, Settings).
   - Solid, but doesn't immediately communicate the unique 5-step data harvesting & NLP extraction pipeline of JSM.

2. **Direction 2: Workflow & Pipeline Focus (Data Processing Hub) [CHOSEN]**
   - Structures the entire Admin experience around the end-to-end scientific paper mining lifecycle:
     `Journals Catalog ➔ Pipeline Config ➔ Job Monitor (Grobid/Crawl) ➔ Corpus Snapshots ➔ Style Profiles`.
   - Replaces the confusing "Không gian giảng viên / Bản Thảo Của Tôi" fake labels with authentic Admin operations.
   - Provides an interactive Pipeline Flow on Tab 0 (Choice A) that serves as the mission control for the Admin.

## User's Direction

- **Role model**: System strictly operates with 2 roles (`user` and `admin`). All capabilities in Admin are for the admin's exclusive use.
- **Orientation**: Chosen **Direction 2 (Workflow & Pipeline Focus)**.
- **Home view**: Chosen **Lựa chọn A (Interactive Pipeline Overview)** — a visual status flow on Tab 0 connecting all stages of the pipeline, with quick actions and direct jump-to-stage navigation.

## Open Questions for Planning (`plan`)

1. Verify mock vs live data bindings for each subview (how `JobMonitorView` and `SnapshotsView` consume backend API vs local mock state).
2. Standardizing common design tokens/components (table rows, status pills, filter bar) across the 5 pipeline views so code remains DRY.

## Risks

1. **Viewport responsiveness**: Expanding beyond `maxWidth: 1080` must handle both standard laptop (1366x768 / 1920x1080) and ultrawide monitors gracefully without stretched elements.
2. **State coordination**: Navigation from Tab 0's interactive flow cards to specific subview tabs must maintain correct tab selection state in `AdminDashboardPage`.

---
**Spec link:** [spec.md](file:///e:/jsm/jsm-fe/plans/admin-ui-workflow-redesign/spec.md)
