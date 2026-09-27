import 'package:equatable/equatable.dart';

import '../../domain/entities/evaluation_history_item.dart';
import '../../domain/entities/evaluation_history_stats.dart';

enum EvaluationHistoryStatus { initial, loading, success, failure }

class EvaluationHistoryState extends Equatable {
  final EvaluationHistoryStatus status;
  final List<EvaluationHistoryItem> items;
  final EvaluationHistoryStats stats;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final String search;
  final String? journal;
  final String? compatibility;
  final String sort;
  final String? errorMessage;
  final bool isDeleting;

  const EvaluationHistoryState({
    this.status = EvaluationHistoryStatus.initial,
    this.items = const [],
    this.stats = const EvaluationHistoryStats(),
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPages = 0,
    this.search = '',
    this.journal,
    this.compatibility,
    this.sort = 'newest',
    this.errorMessage,
    this.isDeleting = false,
  });

  EvaluationHistoryState copyWith({
    EvaluationHistoryStatus? status,
    List<EvaluationHistoryItem>? items,
    EvaluationHistoryStats? stats,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    String? search,
    String? journal,
    String? compatibility,
    String? sort,
    String? errorMessage,
    bool? isDeleting,
    bool clearJournal = false,
    bool clearCompatibility = false,
  }) {
    return EvaluationHistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      stats: stats ?? this.stats,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      search: search ?? this.search,
      journal: clearJournal ? null : (journal ?? this.journal),
      compatibility: clearCompatibility
          ? null
          : (compatibility ?? this.compatibility),
      sort: sort ?? this.sort,
      errorMessage: errorMessage ?? this.errorMessage,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  bool get hasActiveFilters =>
      search.isNotEmpty ||
      (journal != null && journal!.isNotEmpty) ||
      (compatibility != null &&
          compatibility!.isNotEmpty &&
          compatibility != 'ALL');

  @override
  List<Object?> get props => [
    status,
    items,
    stats,
    page,
    limit,
    total,
    totalPages,
    search,
    journal,
    compatibility,
    sort,
    errorMessage,
    isDeleting,
  ];
}
