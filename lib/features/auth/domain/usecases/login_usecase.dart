import '../entities/auth_provider.dart';
import '../entities/auth_result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<AuthResult> call(AuthProvider provider) => repository.login(provider);
}
