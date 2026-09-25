import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/journal_item_entity.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  final http.Client _client;

  HomeRepositoryImpl({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<List<JournalItemEntity>> getFeaturedJournals() async {
    try {
      final uri = Uri.parse('${ApiEndpoints.adminJournals}?per_page=6');
      final res = await _client.get(uri);
      if (res.statusCode == 200) {
        final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final data = body['data'];
        if (data is List) {
          return data.whereType<Map<String, dynamic>>().map((j) {
            final worksCount = (j['works_count'] as num?)?.toInt() ?? 0;
            final citedCount = (j['cited_by_count'] as num?)?.toInt() ?? 0;
            final impact = worksCount > 0
                ? double.parse((citedCount / (worksCount * 10)).toStringAsFixed(2))
                : 3.5;

            return JournalItemEntity(
              id: j['id']?.toString() ?? '',
              title: j['title']?.toString() ?? 'Tạp chí khoa học',
              category: j['publisher']?.toString() ?? 'Khoa học tổng hợp',
              impactFactor: impact.clamp(1.0, 30.0),
              publicationCount: worksCount,
            );
          }).toList();
        }
      }
    } catch (_) {
      // Fallback to empty list when server is unreachable
    }

    return const [];
  }
}
