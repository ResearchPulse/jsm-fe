import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../domain/entities/auth_provider.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_launcher.dart';
import '../datasources/browser_sso_seam.dart';
import '../datasources/desktop_sso_launcher.dart';
import '../datasources/sso_auth_launcher.dart';

/// Auth repository backed by the Central SSO (OIDC Authorization Code +
/// PKCE) launcher. All browser/network details live behind [AuthLauncher];
/// tokens never leave this layer.
class AuthRepositoryImpl implements AuthRepository {
  final AuthLauncher launcher;
  final http.Client? httpClient;

  AuthRepositoryImpl({AuthLauncher? launcher, this.httpClient})
      : launcher = launcher ??
            // Web: the browser navigates to the SSO page and back.
            // Desktop: the system browser opens; a loopback server on the
            // configured redirect port receives the callback in-process.
            (kIsWeb ? SsoAuthLauncher() : DesktopSsoLauncher());

  @override
  Future<void> login(AuthProvider provider) async {
    // Web: the browser navigates away to the SSO authorize page; the flow
    // completes later via [handleCallback] on the /auth/callback page load.
    // Desktop: [DesktopSsoLauncher] opens the system browser and waits for
    // the loopback callback, completing the exchange before returning.
    await launcher.start(provider);
    final desktop = launcher;
    if (desktop is DesktopSsoLauncher) {
      await desktop.awaitCallbackAndComplete();
    }
  }

  /// True when the current page load is the SSO /auth/callback (app start
  /// after the browser redirected back). Requires both the callback path
  /// and authorization code/error query parameters so normal reloads (F5)
  /// or navigations without code are not mistakenly treated as pending callbacks.
  bool isOnCallbackPage() {
    final uri = BrowserSso.currentUri();
    final isCallbackPath =
        uri.path == '/auth/callback' || uri.path.endsWith('/auth/callback');
    final hasCallbackParams = uri.queryParameters.containsKey('code') ||
        uri.queryParameters.containsKey('error');
    return isCallbackPath && hasCallbackParams;
  }

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
    final ssoLauncher = launcher;
    if (ssoLauncher is SsoAuthLauncher) {
      ssoLauncher.clearSession();
    }
    // Attempt best-effort SSO server session invalidation
    try {
      final client = httpClient ?? http.Client();
      final uri = Uri.parse('${ApiEndpoints.ssoIssuer}/api/v1/auth/logout');
      await client.post(uri).timeout(const Duration(seconds: 3));
    } catch (_) {
      // Local session is cleared; ignore network/logout errors
    }
  }

  @override
  Future<String?> currentToken() async {
    final session = await restoreSession();
    return session?.accessToken;
  }
}
