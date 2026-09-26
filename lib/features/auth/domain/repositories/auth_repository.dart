import '../entities/auth_provider.dart';
import '../entities/auth_result.dart';
import '../entities/auth_user.dart';

/// Authentication contract for the app.
///
/// The flow is external-browser based: the app redirects to the Central
/// SSO authorize page, the user authenticates there, and the browser is
/// redirected back to /auth/callback. The app then completes the flow on
/// that page load. The implementation lives in
/// data/repositories/auth_repository_impl.dart.
abstract class AuthRepository {
  /// Starts the external authentication flow for [provider]. On web this
  /// navigates the browser to the SSO authorize page, so this method
  /// completing means "redirect issued", NOT "authenticated". The result
  /// arrives later via [handleCallback] on the callback page load.
  ///
  /// Throws [ServerException] (see core/errors/exceptions.dart) when the
  /// redirect cannot be issued (non-web platform, store failure).
  Future<void> login(AuthProvider provider);

  /// Processes the SSO /auth/callback page load: validates state, exchanges
  /// the code (PKCE), fetches userinfo. Returns null if the current page is
  /// not a callback.
  ///
  /// Throws [ServerException] on an invalid/missing state, missing code, or
  /// a failed token/profile exchange.
  Future<AuthResult?> handleCallback();

  /// Restores a persisted session at app start, or null if none.
  Future<AuthSession?> restoreSession();

  /// Clears the current session, if any.
  Future<void> logout();

  /// The stored SSO access token for calling protected backend endpoints,
  /// or null when not authenticated.
  Future<String?> currentToken();

  /// Mock login for dev/testing: seeds an authenticated session with a mock SSO token
  /// and user profile having the specified [role].
  Future<AuthUser> mockLogin({
    required String sub,
    required String email,
    required String name,
    required String role,
  });
}

/// A persisted authenticated session: user plus the SSO-issued token(s).
/// Tokens stay in the data layer; the presentation layer only sees [user].
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
