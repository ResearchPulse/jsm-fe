# Phase 02: Unified Style & Corpus Analytics Hub (Tab 1)

**Phase ID:** `phase-02-style-corpus-composite-view`  
**Parent Plan:** [`plan.md`](file:///e:/jsm/jsm-fe/plans/admin-3-tabs-simplification/plan.md)  
**Spec Reference:** [`spec.md`](file:///e:/jsm/jsm-fe/plans/admin-3-tabs-simplification/spec.md) (FR-03)  
**Priority:** P1

---

## Objective

Build [`StyleAndCorpusView`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/views/style_and_corpus_view.dart) consolidating **Member 3's deep NLP Style & Rhetorical Move profiles** (`ProfilesReviewView`) and **Corpus Snapshots & Datasets** (`SnapshotsView`) into a single, cohesive academic workspace with a top segmented tab switcher.

---

## Tasks

1. **Create `style_and_corpus_view.dart`:**
   - Top Header with title: *"Hồ Sơ Phong Cách & Đối Chuẩn Học Thuật (NLP)"*.
   - Segmented Switcher (2 sub-tabs):
     - **Sub-tab 0:** `Hồ sơ phong cách & CARS Moves` (embeds [`ProfilesReviewView`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/views/profiles_review_view.dart))
     - **Sub-tab 1:** `Kho bài & Corpus Snapshots` (embeds [`SnapshotsView`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/views/snapshots_view.dart))
   - Support `initialSubTabIndex` and `selectedJournalId` parameters for direct routing from the Command Center.

2. **Integration:**
   - Use `IndexedStack` or clean conditional rendering to preserve sub-view state and avoid redundant refetching when switching between sub-tabs.

---

## Verification & Acceptance Criteria

- Switching between "Hồ sơ phong cách" and "Kho Snapshots" is instantaneous and preserves filters.
- Deep links with `selectedJournalId` correctly pre-select the target journal in ProfilesReviewView.
- `flutter analyze` passes cleanly.
