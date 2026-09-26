import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../data/repositories/student_manuscript_repository_impl.dart';
import '../../domain/repositories/student_manuscript_repository.dart';
import '../../domain/usecases/check_manuscript_usecase.dart';
import '../../domain/usecases/get_available_journals_usecase.dart';
import '../cubit/student_manuscript_checker_cubit.dart';
import '../cubit/student_manuscript_checker_state.dart';
import '../widgets/manuscript_input_card.dart';
import '../widgets/missing_gap_warning_card.dart';
import '../widgets/rhetorical_move_card.dart';
import '../widgets/score_rating_card.dart';
import '../widgets/section_scores_card.dart';
import '../widgets/sentence_length_card.dart';
import '../widgets/stance_card.dart';
import '../widgets/voice_person_card.dart';
import '../widgets/warnings_list_card.dart';

/// Main page for the Student Manuscript Checker feature.
class StudentManuscriptCheckerPage extends StatelessWidget {
  final StudentManuscriptRepository? repository;
  final StudentManuscriptCheckerCubit? cubit;
  final bool showAppBar;

  const StudentManuscriptCheckerPage({
    super.key,
    this.repository,
    this.cubit,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<StudentManuscriptCheckerCubit>.value(
        value: cubit!,
        child: _StudentManuscriptCheckerView(showAppBar: showAppBar),
      );
    }

    try {
      context.read<StudentManuscriptCheckerCubit>();
      return _StudentManuscriptCheckerView(showAppBar: showAppBar);
    } catch (_) {}

    AuthRepository? authRepo;
    try {
      authRepo = context.read<AuthRepository>();
    } catch (_) {}

    final repo = repository ??
        StudentManuscriptRepositoryImpl(
          authRepository: authRepo,
        );

    return BlocProvider<StudentManuscriptCheckerCubit>(
      create: (_) => StudentManuscriptCheckerCubit(
        checkManuscriptUseCase: CheckManuscriptUseCase(repo),
        getAvailableJournalsUseCase: GetAvailableJournalsUseCase(repo),
      )..loadJournals(),
      child: _StudentManuscriptCheckerView(showAppBar: showAppBar),
    );
  }
}

class _StudentManuscriptCheckerView extends StatelessWidget {
  final bool showAppBar;
  const _StudentManuscriptCheckerView({this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          
          double maxCardWidth;
          if (screenWidth >= 1440) {
            maxCardWidth = 1180;
          } else if (screenWidth >= 1200) {
            maxCardWidth = 1050;
          } else {
            maxCardWidth = double.infinity;
          }

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxCardWidth),
              child: BlocBuilder<StudentManuscriptCheckerCubit,
                  StudentManuscriptCheckerState>(
                  builder: (context, state) {
                    if (state is StudentManuscriptCheckerLoading) {
                      return LoadingView(message: state.message);
                    }

                    if (state is StudentManuscriptCheckerFailure) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          ErrorView(
                            message: state.message,
                            onRetry: () {
                              context
                                  .read<StudentManuscriptCheckerCubit>()
                                  .reset();
                            },
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              context
                                  .read<StudentManuscriptCheckerCubit>()
                                  .reset();
                            },
                            child: const Text('Return to Submission Form'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is StudentManuscriptCheckerEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceSoft,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.find_in_page_outlined,
                              size: 48,
                              color: AppColors.textSubtle,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No Manuscript Sections Found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              fontFamily: 'Manrope',
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () {
                              context
                                  .read<StudentManuscriptCheckerCubit>()
                                  .reset();
                            },
                            icon: const Icon(Icons.arrow_back_rounded,
                                size: 16),
                            label: const Text('Submit Another Draft'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is StudentManuscriptCheckerSuccess) {
                  return _ResultsView(state: state);
                }

                // Initial State
                final initial = state is StudentManuscriptCheckerInitial
                    ? state
                    : const StudentManuscriptCheckerInitial();

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 24),
                  child: ManuscriptInputCard(initialState: initial),
                );
              },
            ),
          ),
        );
      },
    ),
  );

    if (!showAppBar) {
      return Container(
        color: AppColors.background,
        child: body,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Manuscript Checker'),
        actions: [
          BlocBuilder<StudentManuscriptCheckerCubit,
              StudentManuscriptCheckerState>(
            builder: (context, state) {
              if (state is StudentManuscriptCheckerSuccess ||
                  state is StudentManuscriptCheckerEmpty ||
                  state is StudentManuscriptCheckerFailure) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<StudentManuscriptCheckerCubit>().reset();
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('New Check'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: body,
    );
  }
}

class _ResultsView extends StatelessWidget {
  final StudentManuscriptCheckerSuccess state;

  const _ResultsView({required this.state});

  @override
  Widget build(BuildContext context) {
    final result = state.result;
    final comparison = result.featureComparison;
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Overall Score & Profile Meta
          ScoreRatingCard(
            result: result,
            journalTitle: state.targetJournalTitle,
            filename: state.manuscriptFileName,
          ),
          const SizedBox(height: 20),

          // 2. High-priority missing GAP warning if present
          if (result.hasMissingGap)
            MissingGapWarningCard(gapWarnings: result.missingGapWarnings),

          // 3. Grid / Columns for Feature Breakdown
          if (isDesktop) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SectionScoresCard(
                          sectionScores: result.sectionScores),
                      const SizedBox(height: 20),
                      SentenceLengthCard(
                          comparison: comparison.sentenceLength),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      VoicePersonCard(
                          comparison: comparison.voiceAndPerson),
                      const SizedBox(height: 20),
                      StanceCard(comparison: comparison.stance),
                      const SizedBox(height: 20),
                      RhetoricalMoveCard(
                        moveWarnings: result.rhetoricalMoveWarnings,
                        totalSections: result.sectionScores.length,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            SectionScoresCard(sectionScores: result.sectionScores),
            const SizedBox(height: 16),
            SentenceLengthCard(comparison: comparison.sentenceLength),
            const SizedBox(height: 16),
            VoicePersonCard(comparison: comparison.voiceAndPerson),
            const SizedBox(height: 16),
            StanceCard(comparison: comparison.stance),
            const SizedBox(height: 16),
            RhetoricalMoveCard(
              moveWarnings: result.rhetoricalMoveWarnings,
              totalSections: result.sectionScores.length,
            ),
          ],

          const SizedBox(height: 20),

          // 4. Complete Warnings & Validated Exemplars List
          WarningsListCard(warnings: result.warnings),

          const SizedBox(height: 24),

          // Bottom Action
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<StudentManuscriptCheckerCubit>().reset();
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Check Another Manuscript'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
