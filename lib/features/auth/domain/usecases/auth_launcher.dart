import '../../../../core/errors/exceptions.dart';
import '../entities/auth_provider.dart';
import '../entities/auth_result.dart';

/// Launches the Central SSO authorization flow and awaits the callback.
/// All platform/browser logic lives in implementations of this seam —
/// never in widgets.
abstract class AuthLauncher {
  /// Starts the external authentication flow for [provider]: builds the
  /// PKCE/S256 authorize URL, persists state+verifier, and redirects the
  /// browser. On web the page navigates away; completion happens later via
  /// [completeFromCallback] when the app restarts on /auth/callback.
  Future<void> start(AuthProvider provider);

  /// Processes the /auth/callback page load: validates state, exchanges the
  /// code (PKCE), fetches userinfo, and returns the authenticated result.
  Future<AuthResult> completeFromCallback();
}

/// Thrown by [AuthLauncher.start] on non-web builds where no browser
/// navigation is available.
class AuthLauncherException extends ServerException {
  const AuthLauncherException(super.message, [super.statusCode]);
}
