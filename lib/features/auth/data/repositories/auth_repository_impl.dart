import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/auth_provider.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';

/// Auth repository implementation.
///
/// =====================================================================
/// BACKEND INTEGRATION POINT — READ BEFORE WIRING UP
/// =====================================================================
/// Target architecture: external-browser authentication. Flutter launches
/// the backend's web login page (email/password) or its Google OAuth URL,
/// the user authenticates in the browser, and the backend redirects back
/// to the app with the session result.
///
/// As of this writing the backend (jsm-be) has NO auth module at all:
/// no web login page, no Google OAuth authorization URL, no
/// callback/redirect endpoint, no token endpoint, no session field
/// names, no logout endpoint. There is nothing real to launch or
/// receive, so this implementation deliberately throws instead of
/// inventing a flow.
///
/// To integrate the real backend:
///   1. Add the confirmed web login URL and Google OAuth URL to
///      core/constants/api_endpoints.dart.
///   2. Add a callback mechanism dependency (e.g. flutter_web_auth_2,
///      plus url_launcher) once the backend's supported redirect URI is
///      agreed (custom scheme / app link / loopback for Windows,
///      in-browser redirect for web builds).
///   3. Implement AuthLauncher (domain/usecases/auth_launcher.dart):
///      build the auth URL (state + PKCE if the backend requires it),
///      launch it, await the callback, validate state and error params.
///   4. In [login] below: call the launcher, map the confirmed callback
///      fields to [AuthResult], and persist via a session store.
///   5. Implement [restoreSession] from the session store (e.g.
///      flutter_secure_storage) for app start.
///   6. Call the confirmed logout endpoint in [logout] and clear the
///      session store.
///   7. Update test/auth/ tests to cover the real mapping (mock the
///      launcher; never hit real OAuth).
///
/// Do NOT return fake users or fake sessions from this class — that
/// would make the app look authenticated when it is not.
/// =====================================================================
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl();

  @override
  Future<AuthResult> login(AuthProvider provider) async {
    throw ServerException(
      'Authentication is not yet connected to the backend. '
      'The backend web login / Google OAuth / callback contract is '
      'required (see auth_repository_impl.dart integration note).',
    );
  }

  @override
  Future<AuthSession?> restoreSession() async {
    // No session storage exists yet — nothing to restore. Replace with
    // the session store's restore once the backend contract lands.
    return null;
  }

  @override
  Future<void> logout() async {
    // No session storage or backend logout endpoint exists yet, so there
    // is nothing to clear. When the contract lands: call the confirmed
    // logout endpoint, then clear the session store.
  }
}
