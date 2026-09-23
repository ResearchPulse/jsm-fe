import '../../../../core/constants/app_constants.dart';

// Non-web (IO/desktop) stand-ins for the browser helpers. Desktop shells are
// out of scope for now; SSO login is web-first.
String currentRedirectUri() => AppConstants.ssoDefaultRedirectUri;

Uri currentBrowserUri() => Uri.parse('http://localhost/');

void cleanCallbackFromHistory() {}

void navigateToUrl(String url) {
  // Desktop navigation (url_launcher / custom scheme) is intentionally not
  // implemented; the web build is the supported target for Central SSO.
  throw UnsupportedError('Central SSO login requires the web build.');
}
