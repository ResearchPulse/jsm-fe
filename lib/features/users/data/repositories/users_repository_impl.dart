import '../../../../core/errors/exceptions.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/users_repository.dart';
import '../datasources/users_api_client.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersApiClient apiClient;

  UsersRepositoryImpl({required AuthRepository authRepository})
      : apiClient = UsersApiClient(
            tokenProvider: () => authRepository.currentToken());

  /// Direct-injection constructor for tests.
  UsersRepositoryImpl.withClient(this.apiClient);

  @override
  Future<UserProfile> createAccount({
    required UserRole role,
    required String email,
    required String fullName,
    required String password,
  }) async {
    if (email.trim().isEmpty || fullName.trim().isEmpty) {
      throw const ServerException('Please fill in all fields.');
    }
    return apiClient.createAccount(
      role: role,
      email: email.trim(),
      fullName: fullName.trim(),
      password: password,
    );
  }
}
