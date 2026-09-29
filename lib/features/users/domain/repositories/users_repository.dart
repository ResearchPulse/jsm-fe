import '../entities/user_profile.dart';

/// Contract for admin user management.
abstract class UsersRepository {
  /// Creates an account. Returns the created [UserProfile].
  ///
  /// Throws [ServerException] on rejection (duplicate email, validation,
  /// auth failure) and [NetworkException] when unreachable.
  Future<UserProfile> createAccount({
    required UserRole role,
    required String email,
    required String fullName,
    required String password,
  });
}
