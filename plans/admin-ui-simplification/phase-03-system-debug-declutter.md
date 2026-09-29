# Phase 03: System & Debug Tab Decluttering

**File:** `phase-03-system-debug-declutter.md`  
**Stories Covered:** P1 (Spec FR-04)  
**Priority:** P1  

---

## 1. Objective
Declutter Tab 2 ("Hệ thống & Kỹ thuật") by removing the outdated 6-stage stepper `TIẾN TRÌNH KHAI PHÁ DỮ LIỆU ĐANG VẬN HÀNH` and the redundant `Bắt đầu phân tích mới` button from `JobMonitorView`. Verify that all 3 sub-tabs (`Nhật Ký Tác Vụ & Debug`, `Cài Đặt Dịch Vụ`, `Quản Lý Người Dùng`) render without overflow or runtime exceptions.

---

## 2. File Modifications

### `lib/features/admin/presentation/views/job_monitor_view.dart`
- Remove the 6-step diagram:
  - Remove `_buildStepperStage` and `_buildStepperLine` widgets.
  - Remove the Container wrapping `TIẾN TRÌNH KHAI PHÁ DỮ LIỆU ĐANG VẬN HÀNH`.
- Remove the redundant `ElevatedButton.icon(onPressed: widget.onTriggerNewAnalysis, label: Text('Bắt đầu phân tích mới'))`.
- Retain the header with refresh button, status filter chips (`Tất cả`, `Đang xử lý`, `Hoàn thành`, `Thất bại`, `Đã hủy`), and the clean task list cards with log viewer and retry actions.

### `lib/features/admin/presentation/views/system_and_debug_view.dart`
- Verify sub-tab switching between `JobMonitorView`, `SettingsView`, and `UsersView` remains smooth and stateful.

---

## 3. Verification Criteria
- `flutter analyze` passes with 0 errors and 0 warnings.
- Tab 2 displays a clean task list without the bulky 6-stage diagram or duplicate action button.
- Sub-tab switching operates seamlessly.
