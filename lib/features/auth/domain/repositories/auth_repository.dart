import '../entities/auth_provider.dart';
import '../entities/auth_result.dart';
import '../entities/auth_user.dart';

/// Authentication contract for the app.
///
/// The flow is external-browser based: the app launches the backend's
/// authentication page (email/password or Google), the user authenticates
/// there, and the app receives the result via the agreed callback
/// mechanism. The implementation lives in
/// data/repositories/auth_repository_impl.dart.
abstract class AuthRepository {
  /// Launches the external authentication flow for [provider] and
  /// returns the result once the backend redirects back.
  ///
  /// Throws [ServerException] (see core/errors/exceptions.dart) on
  /// failure, user cancellation, or an invalid callback.
  Future<AuthResult> login(AuthProvider provider);

  /// Restores a persisted session at app start, or null if none.
  Future<AuthSession?> restoreSession();

  /// Clears the current session, if any.
  Future<void> logout();
}

/// A persisted authenticated session: user plus the backend-issued
/// token(s). Token field names are intentionally generic until the
/// backend contract is confirmed.
class AuthSession {
  final AuthUser user;
  final String? accessToken;
  final String? refreshToken;

  const AuthSession({
    required this.user,
    this.accessToken,
    this.refreshToken,
  });
}
