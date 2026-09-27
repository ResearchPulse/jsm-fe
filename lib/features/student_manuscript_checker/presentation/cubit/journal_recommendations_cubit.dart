import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/journal_recommendation_item.dart';
import '../../domain/repositories/student_manuscript_repository.dart';
import 'journal_recommendations_state.dart';

class JournalRecommendationsCubit extends Cubit<JournalRecommendationsState> {
  final StudentManuscriptRepository repository;

  JournalRecommendationsCubit({required this.repository})
    : super(const JournalRecommendationsState());

  Future<void> init() async {
    try {
      final journals = await repository.getAvailableJournals();
      emit(state.copyWith(availableJournalsCount: journals.length));
    } catch (_) {
      // Non-blocking fallback
    }
  }

  void selectFile({required String filename, required List<int> bytes}) {
    emit(
      state.copyWith(
        fileName: filename,
        fileBytes: bytes,
        clearEvaluationId: true,
      ),
    );
  }

  void selectEvaluationId(String evaluationId, String fileName) {
    emit(
      state.copyWith(
        selectedEvaluationId: evaluationId,
        fileName: fileName,
        clearFile: true,
      ),
    );
  }

  void clearSelection() {
    emit(
      state.copyWith(
        clearFile: true,
        clearEvaluationId: true,
        status: JournalRecommendationsStatus.initial,
        clearDetailedView: true,
      ),
    );
  }

  void viewComparison(JournalRecommendationItem item) {
    emit(state.copyWith(selectedJournalForDetailedView: item));
  }

  void closeComparison() {
    emit(state.copyWith(clearDetailedView: true));
  }

  Future<void> submitRecommendationRequest() async {
    if ((state.fileBytes == null || state.fileBytes!.isEmpty) &&
        (state.selectedEvaluationId == null ||
            state.selectedEvaluationId!.isEmpty)) {
      emit(
        state.copyWith(
          status: JournalRecommendationsStatus.failure,
          errorMessage: 'Vui lòng tải lên bản thảo hoặc chọn lịch sử đánh giá.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: JournalRecommendationsStatus.loading,
        pipelineProgress: 0.15,
        pipelineStage: 'PREPARING_MANUSCRIPT',
        pipelineMessage: 'Trích xuất đặc trưng bản thảo...',
        clearDetailedView: true,
      ),
    );

    try {
      // Simulate truthful pipeline steps
      await Future.delayed(const Duration(milliseconds: 300));
      emit(
        state.copyWith(
          pipelineProgress: 0.45,
          pipelineStage: 'FETCHING_JOURNALS',
          pipelineMessage:
              'Tải ${state.availableJournalsCount > 0 ? state.availableJournalsCount : "các"} hồ sơ tạp chí sẵn có trong hệ thống...',
        ),
      );

      await Future.delayed(const Duration(milliseconds: 300));
      emit(
        state.copyWith(
          pipelineProgress: 0.75,
          pipelineStage: 'COMPARING_PROFILES',
          pipelineMessage:
              'Đối chuẩn văn phong đa chiều & tính điểm tương thích...',
        ),
      );

      final response = await repository.getJournalRecommendations(
        fileBytes: state.fileBytes,
        filename: state.fileName,
        evaluationId: state.selectedEvaluationId,
      );

      emit(
        state.copyWith(
          status: JournalRecommendationsStatus.success,
          recommendationResponse: response,
          pipelineProgress: 1.0,
          pipelineStage: 'COMPLETED',
          pipelineMessage: 'Hoàn tất xếp hạng tạp chí phù hợp',
        ),
      );
    } on ServerException catch (e) {
      emit(
        state.copyWith(
          status: JournalRecommendationsStatus.failure,
          errorMessage: e.message,
        ),
      );
    } on NetworkException catch (e) {
      emit(
        state.copyWith(
          status: JournalRecommendationsStatus.failure,
          errorMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: JournalRecommendationsStatus.failure,
          errorMessage: 'Đã xảy ra lỗi khi tạo gợi ý: $e',
        ),
      );
    }
  }

  void reset() {
    emit(
      JournalRecommendationsState(
        availableJournalsCount: state.availableJournalsCount,
      ),
    );
  }
}
