import 'package:web/web.dart' as web;

import '../../../../core/constants/api_endpoints.dart';

/// Browser-only helpers for the SSO flow. Keep all `window` usage in this
/// file (plus browser_*.dart) — never in widgets or business logic.
/// The redirect URI is configurable (SSO_REDIRECT_URI); when the app is
/// actually served from the configured origin we use the live origin so
/// dev ports other than the default still work.
String currentRedirectUri() {
  final configured = ApiEndpoints.ssoRedirectUri;
  final origin = web.window.location.origin;
  final configuredOrigin = Uri.parse(configured).origin;
  return origin == configuredOrigin
      ? '$origin/auth/callback'
      : configured;
}

Uri currentBrowserUri() => Uri.parse(web.window.location.href);

/// Replaces the callback query parameters in the browser history.
void cleanCallbackFromHistory() {
  web.window.history.replaceState(null, '', web.window.location.pathname);
}

/// Full-page navigation to the SSO authorize URL.
void navigateToUrl(String url) => web.window.location.href = url;
