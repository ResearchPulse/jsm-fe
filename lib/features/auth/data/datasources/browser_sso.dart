import 'package:web/web.dart' as web;

import '../../../../core/constants/api_endpoints.dart';

/// Browser-only helpers for the SSO flow. Keep all `window` usage in this
/// file (plus browser_*.dart) — never in widgets or business logic.
/// The redirect URI is configurable (SSO_REDIRECT_URI); when the app is
/// actually served from the configured origin we use the live origin so
/// dev ports other than the default still work.
String currentRedirectUri() {
  final origin = web.window.location.origin;
  if (origin.isNotEmpty && origin != 'null') {
    return '$origin/auth/callback';
  }
  return ApiEndpoints.ssoRedirectUri;
}

Uri currentBrowserUri() => Uri.parse(web.window.location.href);

/// Replaces the callback query parameters and path in browser history
/// so reloading (F5) does not re-trigger the callback flow.
void cleanCallbackFromHistory() {
  web.window.history.replaceState(null, '', '/');
}

/// Full-page navigation to the SSO authorize URL.
void navigateToUrl(String url) => web.window.location.href = url;
