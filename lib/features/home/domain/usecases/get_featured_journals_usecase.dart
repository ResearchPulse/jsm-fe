import '../entities/journal_item_entity.dart';
import '../repositories/home_repository.dart';

class GetFeaturedJournalsUseCase {
  final HomeRepository repository;

  const GetFeaturedJournalsUseCase(this.repository);

  Future<List<JournalItemEntity>> call() async {
    return await repository.getFeaturedJournals();
  }
}
