import '../repositories/auth_repository.dart';

class RestoreSessionUseCase {
  final AuthRepository repository;

  const RestoreSessionUseCase(this.repository);

  Future<AuthSession?> call() => repository.restoreSession();
}
