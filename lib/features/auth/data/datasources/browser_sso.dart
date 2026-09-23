import 'package:web/web.dart' as web;

/// Browser-only helpers for the SSO flow. Keep all `window` usage in this
/// file (plus browser_*.dart) — never in widgets or business logic.
String currentRedirectUri() =>
    '${web.window.location.origin}/auth/callback';

Uri currentBrowserUri() => Uri.parse(web.window.location.href);

/// Replaces the callback query parameters in the browser history.
void cleanCallbackFromHistory() {
  web.window.history.replaceState(null, '', web.window.location.pathname);
}

/// Full-page navigation to the SSO authorize URL.
void navigateToUrl(String url) => web.window.location.href = url;
