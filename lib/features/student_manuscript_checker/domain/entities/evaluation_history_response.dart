import 'package:equatable/equatable.dart';

import 'evaluation_history_item.dart';

class EvaluationHistoryResponse extends Equatable {
  final List<EvaluationHistoryItem> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const EvaluationHistoryResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory EvaluationHistoryResponse.fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .whereType<Map<String, dynamic>>()
        .map(EvaluationHistoryItem.fromMap)
        .toList();

    return EvaluationHistoryResponse(
      items: items,
      page: (map['page'] as num?)?.toInt() ?? 1,
      limit: (map['limit'] as num?)?.toInt() ?? 10,
      total: (map['total'] as num?)?.toInt() ?? 0,
      totalPages: (map['total_pages'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [items, page, limit, total, totalPages];
}
