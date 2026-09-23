import '../entities/journal_item_entity.dart';

abstract class HomeRepository {
  Future<List<JournalItemEntity>> getFeaturedJournals();
}
