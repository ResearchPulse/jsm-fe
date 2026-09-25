# Brainstorm: Admin Navigation Simplification (3-Tab Core Architecture)

**Date:** 2026-09-26  
**Status:** Decided  
**Target Module:** `jsm-fe` (Flutter Admin Console)

---

## Ideas Explored

1. **Status Quo (8 fragmented tabs):**
   - Overview, Journals, Configurations, Job Monitor, Snapshots, Profiles Review, Settings, Users.
   - High cognitive load; redundant navigation since the All-in-One Command Center already handles 80% of daily mining workflows in a single screen.

2. **Direction 1: 3 Core Research Tabs (Selected by User):**
   - **Tab 1: Trung tâm Tạp chí (Khai phá & Pipeline):** Default workspace. 1-touch preset mining, live 4-stage stepper, and quick style metrics.
   - **Tab 2: Đối chuẩn & Hồ sơ Chuyên sâu (Style & Corpus):** Unified NLP analytics hub. Sub-tab A: Member 3 NLP Style & Rhetorical Move profiles; Sub-tab B: Corpus Snapshots & dataset exports.
   - **Tab 3: Hệ thống & Kỹ thuật (System & Debug):** Technical administration. Sub-tab A: Job Monitor & article retry/logs; Sub-tab B: Services config (MinIO, GROBID, OpenAlex) & user accounts.

3. **Direction 2: 2 Ultra-Minimalist Tabs:**
   - Command Center + Corpus Analytics; system settings moved to header dropdown. Dismissed in favor of keeping a dedicated technical tab for debugging.

4. **Direction 3: Dashboard + Workspace Model:**
   - Keeping the high-level dashboard as tab 0. Dismissed to eliminate unnecessary landing screens and get straight to work.

---

## User's Direction

- **Choice:** Direction 1 (3 Core Tabs).
- **Default Landing Tab:** Tab 1 (Trung tâm Tạp chí) opens immediately upon application launch.
- **Sub-navigation Pattern:** Clean segmented switcher at the top of Tab 2 and Tab 3 to preserve minimal visual clutter while keeping deep tools accessible in 1 tap.
- **Alignment with Member 3:** Tab 2 provides full dedicated space for Member 3's NLP output (Hyland Stance, CARS Rhetorical Moves, Sentence Length Distributions, and Corpus Comparisons).

---

## Open Questions

- *Index remapping:* Existing deep links (`onNavigateToTab(3)`, `onNavigateToTab(5)`) will be updated to target the new 0, 1, 2 index layout and sub-tab selection.

---

## Risks

- **Route / Index breaks:** Handled gracefully by updating `AdminDashboardPage` and `AdminSidebar` in sync with a clean enum or index router.
