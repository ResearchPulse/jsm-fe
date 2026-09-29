import '../../../../core/constants/app_constants.dart';
import 'desktop_sso_launcher.dart';

// Non-web (IO/desktop) implementations for the browser helpers.
String currentRedirectUri() => AppConstants.ssoDefaultRedirectUri;

Uri currentBrowserUri() => Uri.parse('http://localhost/');

void cleanCallbackFromHistory() {}

Future<void> navigateToUrl(String url) async {
  await defaultDesktopBrowserLauncher(url);
}
