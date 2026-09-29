# Phase 02: Real-time "Đang phân tích" Progress Card

**File:** `phase-02-realtime-analysis-card.md`  
**Stories Covered:** P1 (Spec FR-02)  
**Priority:** P1  

---

## 1. Objective
Replace the 4-box technical pipeline card (`OpenAlex`, `GROBID / MinIO`, `Normalizer`, `NLP Engine`) in `JournalCommandCenterPanel` with a streamlined, user-friendly card titled **"Đang phân tích"** (or **"Tiến độ phân tích"**). The card displays a clean progress bar, percentage, and a live ticker showing the exact article being analyzed, with zero backend jargon.

---

## 2. File Modifications

### `lib/features/admin/presentation/widgets/journal_command_center_panel.dart`
- Replace `_buildPipelineStatusCard()` with `_buildActiveAnalysisCard()`.
- Title: `Đang phân tích` (or `Tiến độ phân tích` when complete).
- Subtitle: `Cập nhật tiến độ bóc tách và phân tích học thuật theo thời gian thực.`
- Visual elements:
  - Progress bar: Linear progress indicator showing percentage of completed articles (`completed / total`).
  - Active article ticker:
    - If status is `RUNNING` or `MINING`:
      - Icon: Animated/pulsing `Icons.article_rounded` (or subtle spinner).
      - Text: `Đang phân tích bài ${currentArticleIndex}/${totalArticles}: "${currentArticleTitle}"`
    - If status is `COMPLETED`:
      - Icon: `Icons.check_circle_rounded` with green color.
      - Text: `Đã phân tích hoàn tất ${completedArticles}/${totalArticles} bài báo`
      - If there are failed articles: Show warning chip `1 bài lỗi` with deep-link `Xem chi tiết logs ➔` to Tab 2.
- Remove all technical jargon (GROBID, TEI XML, MinIO, Normalizer, Celery) from the main card.

---

## 3. Verification Criteria
- `flutter analyze` passes with 0 errors and 0 warnings.
- The 4 technical boxes are completely replaced with the streamlined "Đang phân tích" card.
- Current active article name and progress are clearly rendered.
