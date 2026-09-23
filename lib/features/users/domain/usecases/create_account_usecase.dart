import '../entities/user_profile.dart';
import '../repositories/users_repository.dart';

class CreateAccountUseCase {
  final UsersRepository repository;

  const CreateAccountUseCase(this.repository);

  Future<UserProfile> call({
    required UserRole role,
    required String email,
    required String fullName,
    required String password,
  }) =>
      repository.createAccount(
        role: role,
        email: email,
        fullName: fullName,
        password: password,
      );
}
