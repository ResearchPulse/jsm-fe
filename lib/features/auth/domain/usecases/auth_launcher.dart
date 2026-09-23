import '../../../../core/errors/exceptions.dart';
import '../entities/auth_provider.dart';
import '../entities/auth_result.dart';

/// Launches the external-browser authentication flow and awaits the
/// backend's callback. Platform/browser logic must live ONLY in
/// implementations of this interface — never in widgets.
///
/// =====================================================================
/// BACKEND INTEGRATION POINT — READ BEFORE WIRING UP
/// =====================================================================
/// The backend (jsm-be) currently exposes NO authentication contract:
/// no web login page, no Google OAuth authorization URL, no
/// callback/redirect endpoint, no agreed redirect URI (custom scheme,
/// app link, localhost port, or web redirect), no state/PKCE
/// requirement, no token/session field names. Nothing real can be
/// launched or awaited, so this implementation throws instead of
/// fabricating a flow.
///
/// To integrate the real backend:
///   1. Confirm the redirect mechanism the backend supports:
///      - Windows/desktop: custom URI scheme or localhost callback
///        (e.g. flutter_web_auth_2 with a loopback or scheme).
///      - Web build: in-browser redirect back to the app URL.
///   2. Add the confirmed URLs to core/constants/api_endpoints.dart
///      (web login URL, Google OAuth URL, and redirect URI).
///   3. Build the auth URL here: append state (and PKCE if the backend
///      requires it) and the redirect URI; keep state for validation.
///   4. Launch it (url_launcher / flutter_web_auth_2) and await the
///      callback.
///   5. In the callback: reject error params (access_denied etc.),
///      validate state, then map the confirmed token/session fields to
///      [AuthResult]. Reject anything malformed.
///   6. Update test/auth/auth_launcher tests (mock the browser; never
///      hit real OAuth from tests).
/// =====================================================================
class AuthLauncher {
  const AuthLauncher();

  /// Starts the external authentication flow for [provider] and
  /// completes with the authenticated result.
  Future<AuthResult> start(AuthProvider provider) async {
    throw ServerException(
      'External authentication is not yet connected to the backend. '
      'The backend web login / Google OAuth / callback contract is '
      'required (see auth_launcher.dart integration note).',
    );
  }
}
