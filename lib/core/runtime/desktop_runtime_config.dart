/// Runtime values negotiated by the Windows runner for one desktop launch.
///
/// The native runner passes these values as Dart entrypoint arguments. They
/// intentionally live outside `.env`: a packaged desktop launch must not be
/// able to fall back to a stale API port or callback port from bundled config.
class DesktopRuntimeConfig {
  static const apiBaseUrlArgument = '--jsm-api-base-url';
  static const apiPortArgument = '--jsm-api-port';
  static const ssoCallbackPortArgument = '--jsm-sso-callback-port';
  static const profileArgument = '--jsm-profile';
  static const runtimeTokenArgument = '--jsm-runtime-token';
  static const runtimeTokenHeader = 'X-JSM-Runtime-Token';

  final Uri apiBaseUri;
  final int apiPort;
  final int ssoCallbackPort;
  final String profile;
  final String runtimeToken;

  const DesktopRuntimeConfig._({
    required this.apiBaseUri,
    required this.apiPort,
    required this.ssoCallbackPort,
    required this.profile,
    required this.runtimeToken,
  });

  /// Parses the native runner contract. Returns null for non-desktop launches
  /// that have no negotiated runtime arguments.
  static DesktopRuntimeConfig? fromArgs(Iterable<String> args) {
    final values = <String, String>{};
    for (final arg in args) {
      for (final key in const [
        apiBaseUrlArgument,
        apiPortArgument,
        ssoCallbackPortArgument,
        profileArgument,
        runtimeTokenArgument,
      ]) {
        final prefix = '$key=';
        if (arg.startsWith(prefix)) {
          values[key] = arg.substring(prefix.length);
          break;
        }
      }
    }
    if (values.isEmpty) return null;

    String required(String key) {
      final value = values[key];
      if (value == null || value.isEmpty) {
        throw FormatException('Missing desktop runtime argument: $key');
      }
      return value;
    }

    final profile = required(profileArgument).toLowerCase();
    if (profile != 'desktop') {
      throw FormatException('Unsupported desktop runtime profile: $profile');
    }

    final apiPort = _parsePort(required(apiPortArgument), apiPortArgument);
    final ssoCallbackPort = _parsePort(
      required(ssoCallbackPortArgument),
      ssoCallbackPortArgument,
    );
    if (apiPort == ssoCallbackPort) {
      throw const FormatException(
        'Desktop API and SSO callback ports must be different.',
      );
    }

    final apiBaseUri = Uri.tryParse(required(apiBaseUrlArgument));
    if (apiBaseUri == null ||
        (apiBaseUri.scheme != 'http' && apiBaseUri.scheme != 'https') ||
        apiBaseUri.host.isEmpty ||
        !{'127.0.0.1', 'localhost', '::1'}.contains(apiBaseUri.host) ||
        apiBaseUri.port != apiPort ||
        apiBaseUri.userInfo.isNotEmpty ||
        apiBaseUri.query.isNotEmpty ||
        apiBaseUri.fragment.isNotEmpty ||
        !apiBaseUri.path.startsWith('/')) {
      throw const FormatException('Invalid loopback desktop API base URL.');
    }

    final runtimeToken = required(runtimeTokenArgument);
    if (runtimeToken.length < 16) {
      throw const FormatException('Desktop runtime token is too short.');
    }

    return DesktopRuntimeConfig._(
      apiBaseUri: _withoutTrailingSlash(apiBaseUri),
      apiPort: apiPort,
      ssoCallbackPort: ssoCallbackPort,
      profile: profile,
      runtimeToken: runtimeToken,
    );
  }

  String get apiBaseUrl => apiBaseUri.toString();

  Uri get apiReadyUri => apiBaseUri.replace(path: '/ready');

  Uri get ssoCallbackUri => Uri(
    scheme: 'http',
    host: 'localhost',
    port: ssoCallbackPort,
    path: '/auth/callback',
  );

  Map<String, String> get localRuntimeHeaders => {
    runtimeTokenHeader: runtimeToken,
  };

  static int _parsePort(String value, String argument) {
    final port = int.tryParse(value);
    if (port == null || port < 1 || port > 65535) {
      throw FormatException('Invalid port for $argument: $value');
    }
    return port;
  }

  static Uri _withoutTrailingSlash(Uri uri) {
    final path = uri.path.replaceFirst(RegExp(r'/+$'), '');
    return uri.replace(path: path.isEmpty ? '/' : path);
  }
}
