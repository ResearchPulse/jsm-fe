import '../../domain/entities/journal_item_entity.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  @override
  Future<List<JournalItemEntity>> getFeaturedJournals() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock data
    return const [
      JournalItemEntity(
        id: '1',
        title: 'IEEE Access',
        category: 'Computer Science',
        impactFactor: 3.476,
        publicationCount: 1500,
      ),
      JournalItemEntity(
        id: '2',
        title: 'Nature Machine Intelligence',
        category: 'Artificial Intelligence',
        impactFactor: 16.65,
        publicationCount: 300,
      ),
      JournalItemEntity(
        id: '3',
        title: 'Journal of Medical Systems',
        category: 'Medical',
        impactFactor: 4.46,
        publicationCount: 450,
      ),
    ];
  }
}
