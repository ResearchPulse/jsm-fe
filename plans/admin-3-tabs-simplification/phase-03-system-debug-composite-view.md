# Phase 03: Unified System Monitor & Settings Hub (Tab 2)

**Phase ID:** `phase-03-system-debug-composite-view`  
**Parent Plan:** [`plan.md`](file:///e:/jsm/jsm-fe/plans/admin-3-tabs-simplification/plan.md)  
**Spec Reference:** [`spec.md`](file:///e:/jsm/jsm-fe/plans/admin-3-tabs-simplification/spec.md) (FR-04)  
**Priority:** P1

---

## Objective

Build [`SystemAndDebugView`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/views/system_and_debug_view.dart) consolidating **Job Monitoring & Article Debugging** (`JobMonitorView`), **Service Configuration** (`SettingsView`), and **User Administration** (`UsersView`) into a single administrative hub with a top segmented tab switcher.

---

## Tasks

1. **Create `system_and_debug_view.dart`:**
   - Top Header with title: *"Hệ Thống, Giám Sát & Cài Đặt Kỹ Thuật"*.
   - Segmented Switcher (2 sub-tabs):
     - **Sub-tab 0:** `Nhật ký tác vụ & Debug (Job Monitor)` (embeds [`JobMonitorView`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/views/job_monitor_view.dart) with full retry/cancel controls).
     - **Sub-tab 1:** `Cài đặt dịch vụ & Người dùng` (embeds [`SettingsView`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/views/settings_view.dart) and [`UsersView`](file:///e:/jsm/jsm-fe/lib/features/admin/presentation/views/users_view.dart) in a clean card layout).
   - Support `initialSubTabIndex` parameter for deep navigation (e.g. from Command Center's "Xem chi tiết logs").

2. **Integration:**
   - Preserve all existing functions: cancel job, retry failed articles, update service endpoints (MinIO/Grobid), and create/edit users.

---

## Verification & Acceptance Criteria

- Switching between "Nhật ký tác vụ" and "Cài đặt dịch vụ" works seamlessly.
- Article retry and cancellation actions operate without errors.
- `flutter analyze` passes cleanly.
