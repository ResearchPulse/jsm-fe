import '../entities/auth_provider.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  /// Issues the SSO redirect; does NOT complete the login (see
  /// AuthRepository.login).
  Future<void> call(AuthProvider provider) => repository.login(provider);
}
