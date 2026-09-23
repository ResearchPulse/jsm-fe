import '../datasources/browser_sso_stub.dart' as browser;

/// Test seam for the browser-level functions used by the SSO flow.
/// Production code calls these; tests can override them.
class BrowserSso {
  static String Function() redirectUri = browser.currentRedirectUri;
  static Uri Function() currentUri = browser.currentBrowserUri;
  static void Function() cleanHistory = browser.cleanCallbackFromHistory;
  static void Function(String) navigate = browser.navigateToUrl;
}
