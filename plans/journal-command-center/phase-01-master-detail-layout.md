# Phase 01: Master-Detail Layout in JournalsView

**Phase ID:** `phase-01-master-detail-layout`  
**Parent Plan:** [`plan.md`](file:///e:/jsm/jsm-fe/plans/journal-command-center/plan.md)  
**Spec Reference:** [`spec.md`](file:///e:/jsm/jsm-fe/plans/journal-command-center/spec.md) (FR-01)  
**Priority:** P1

---

## Objective

Transform [`journals_view.dart`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/views/journals_view.dart) from a single-column layout into a responsive Master-Detail workspace:
- Left Column (38% width): Journal Catalog list with active selection highlight.
- Right Column (62% width): Sticky Command Center container with an initial placeholder state when no journal is selected.

---

## Tasks

1. **State Management:**
   - Add `Map<String, dynamic>? _selectedJournal` to `_JournalsViewState`.
   - On selecting any journal card, update `_selectedJournal` and automatically load its configuration, latest job, and style profile.

2. **Responsive Split Layout:**
   - In `build()`, wrap content in a `LayoutBuilder`.
   - On desktop ($\ge 1100\text{px}$), render a `Row` with 2 flex children:
     - Left (flex 4): Catalog list (Search, Domain filter, Status filter, Journal Cards).
     - Right (flex 6): `JournalCommandCenter` widget.
   - On narrower widths ($< 1100\text{px}$), fall back to single-column with tap-to-open bottom sheet or modal dialog.

3. **Empty State Placeholder:**
   - When `_selectedJournal == null`, the right panel displays a clean, inviting card with an academic icon and guide text:
     *"Chọn một tạp chí từ danh sách bên trái để mở trung tâm khai phá và xem hồ sơ phong cách NLP tức thì."*

---

## Verification & Acceptance Criteria

- Clicking any journal in the left catalog highlights its border with `AppColors.primary` and mounts the right panel.
- Resizing the window maintains responsive proportions without overflow errors.
- `flutter analyze` passes cleanly.
