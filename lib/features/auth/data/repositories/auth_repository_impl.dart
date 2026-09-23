import '../../domain/entities/auth_provider.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_launcher.dart';
import '../datasources/browser_sso_seam.dart';
import '../datasources/sso_auth_launcher.dart';

/// Auth repository backed by the Central SSO (OIDC Authorization Code +
/// PKCE) launcher. All browser/network details live behind [AuthLauncher];
/// tokens never leave this layer.
class AuthRepositoryImpl implements AuthRepository {
  final AuthLauncher launcher;

  AuthRepositoryImpl({AuthLauncher? launcher})
      : launcher = launcher ?? SsoAuthLauncher();

  @override
  Future<void> login(AuthProvider provider) async {
    // On web the browser navigates away to the SSO authorize page; the flow
    // completes later via [handleCallback] on the /auth/callback page load.
    await launcher.start(provider);
  }

  /// True when the current page load is the SSO /auth/callback (app start
  /// after the browser redirected back).
  bool isOnCallbackPage() => BrowserSso.currentUri().path == '/auth/callback';

  /// Processes the callback page load: validates state, exchanges the code
  /// with PKCE, fetches userinfo. Returns the authenticated result, or
  /// null if this page load is not a callback.
  @override
  Future<AuthResult?> handleCallback() async {
    if (!isOnCallbackPage()) return null;
    return launcher.completeFromCallback();
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final ssoLauncher = launcher;
    if (ssoLauncher is SsoAuthLauncher) {
      final snapshot = await ssoLauncher.restoreStoredSession();
      if (snapshot == null) return null;
      return AuthSession(
        user: AuthUser(
          sub: snapshot.userInfo.sub,
          email: snapshot.userInfo.email,
          name: snapshot.userInfo.name,
          picture: snapshot.userInfo.picture,
        ),
        accessToken: snapshot.tokens.accessToken,
        refreshToken: snapshot.tokens.refreshToken,
      );
    }
    return null;
  }

  @override
  Future<void> logout() async {
    // No SSO logout endpoint is confirmed in the backend contract; only
    // local session state is cleared (tokens, user, pending request). If a
    // confirmed endpoint appears, call it here — do not invent one.
    final ssoLauncher = launcher;
    if (ssoLauncher is SsoAuthLauncher) {
      ssoLauncher.clearSession();
    }
  }
}
