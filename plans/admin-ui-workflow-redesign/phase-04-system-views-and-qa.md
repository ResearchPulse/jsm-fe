# Phase 04: System Views, Language Harmonization & QA

**Phase ID:** `phase-04-system-views-and-qa`
**Status:** not_started
**Mapped Stories:** [P1] Consistent system views and verification

---

## Objectives

1. Modernize `UsersView` (Tab 7) and `SettingsView` (Tab 6) to adhere to the same responsive design language and full-width layout.
2. Complete end-to-end anti-slop copy audit: verify that 100% of labels, tooltips, and dialogs across the Admin console use unified, professional Vietnamese.
3. Verify type safety and zero analyzer warnings (`flutter analyze`).
4. Validate live rendering via hot restart on the desktop application.

---

## Affected Files

- `lib/features/users/presentation/views/users_view.dart`
- `lib/features/admin/presentation/views/settings_view.dart`
- Entire `lib/features/admin/` presentation directory.

---

## Tasks

1. In `users_view.dart`:
   - Expand layout, add clean account creation cards and user role distribution indicators.
2. In `settings_view.dart`:
   - Un-constrain width, organize settings into clear categories (Lưu trữ & Cache, Polite Pool & Giới hạn API, Kết nối SSO Lab).
3. Run `flutter analyze` and resolve any linter issues.
4. Verify hot restart rendering and smooth tab switching.

---

## Acceptance Criteria

- [ ] All 8 tabs in Admin Console render without layout overflows or styling glitches.
- [ ] Language is 100% unified in Vietnamese.
- [ ] `flutter analyze` reports 0 issues.
