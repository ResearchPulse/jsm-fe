# Brainstorm: Journal All-in-One Command Center (Minimal Actions & Unified Pipeline UX)

**Date:** 2026-09-26  
**Context:** JSM (Journal Style Miner) Admin Console & Data Pipeline Frontend (`jsm-fe`)

---

## 1. Challenge & User Problem

Currently, an Admin or Researcher wanting to mine and analyze a Journal must navigate across multiple disconnected subviews:
1. **`JournalsView`**: Search, discover, or import journals from OpenAlex.
2. **`ConfigurationsView`**: Manually fill in crawler configuration forms (year range, target articles, domain, reference corpus).
3. **`JobMonitorView`**: Track queue status, live pipeline stages (`Harvester ➔ Fetcher ➔ Parser ➔ Normalizer`), and error logs.
4. **`ProfilesReviewView`**: View Member 3's NLP Style Profile results (Stance, Sentence stats, Voice, Keyness).

This requires 4–5 navigation hops, dozens of clicks, and manual form entries. The user requested:
> *"ít thao tác nhất được ko nhỉ, keep it simple"* (Minimal actions, keep it simple / zero-friction).

---

## 2. Ideas Explored

1. **Direction 1: Inline 1-Click Action on Journal Card**
   - Each Journal card in the catalog has a single `[ Khai phá nhanh ]` button with smart presets (300 articles, 2022–2024).
   - Clicking expands a mini-pipeline stepper directly inside the card.
   - *Pros:* Zero navigation required.
   - *Cons:* Limited card height makes showing detailed live progress, logs, and rich NLP radar charts cramped.

2. **Direction 2: All-in-One Command Center (Selected)**
   - A unified Master-Detail 2-column workspace directly embedded in `JournalsView`.
   - **Left Column (35–40%):** Quick search/filter + Journal selection + 1-touch preset button.
   - **Right Column (60–65%):** Unified Execution & Live Results Panel:
     - *State 1 (Idle):* Journal summary & readiness status.
     - *State 2 (Running):* Real-time 4-stage pipeline stepper (`OpenAlex ➔ Grobid/MinIO ➔ Normalizer ➔ NLP Engine`) with animated progress counters.
     - *State 3 (Completed):* Instant NLP Style Profile overview (sentence length P10..P90, active/passive voice, Hyland stance, quick radar chart) without changing pages.
   - *Pros:* Keeps complete context, maximizes desktop screen space (Windows Flutter app), reduces operations to **1 click**.
   - *Cons:* Requires modular side-panel widget composition.

3. **Direction 3: Smart Preset Batch Wizard**
   - Pre-packaged domain bundles (e.g., "Top 5 AI Journals", "Top 5 Bioinformatics").
   - *Pros:* Fast for bulk seeding.
   - *Cons:* Inflexible when the user wants to inspect or work on a single specific journal.

---

## 3. User's Decisions & Clarifications

- **Direction Chosen:** **Direction 2 (All-in-One Command Center)**.
- **Placement (Choice A):** Directly upgrade and integrate into [`journals_view.dart`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/views/journals_view.dart). When selecting a Journal, the right panel seamlessly acts as the Command & Results Center.
- **Preset Mechanism:** Agreed to completely hide parameter forms behind a smart 1-touch preset (`Target: 300 articles`, `Years: 2022–2024`, `Domain: Auto-detected`). Advanced parameter overrides remain accessible via an optional expandable "Tùy chỉnh" toggle.

---

## 4. Key Value Proposition

- **Zero-Friction 1-Click Workflow:** Select Journal ➔ Click `[ Bắt đầu Khai phá & Phân tích ]` ➔ Watch real-time execution ➔ View NLP Style Profile at the same place.
- **Seamless Handoff:** Bridges Member 2's Data Pipeline (`Harvester ➔ Grobid ➔ Normalizer`) directly into Member 3's NLP Engine (`POST /api/v1/nlp/build-profile`) in a continuous user journey.

---

## 5. Next Steps

- Generate formal Specification at `plans/journal-command-center/spec.md`.
- Handoff to `plan` for phase breakdown and implementation.
