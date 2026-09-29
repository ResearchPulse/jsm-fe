import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/core/constants/api_endpoints.dart';
import 'package:jsm_fe/core/runtime/desktop_runtime_config.dart';

void main() {
  tearDown(ApiEndpoints.clearRuntime);

  test('parses negotiated API and SSO ports independently', () {
    final config = DesktopRuntimeConfig.fromArgs([
      '--jsm-api-base-url=http://127.0.0.1:43127/api/v1',
      '--jsm-api-port=43127',
      '--jsm-sso-callback-port=43128',
      '--jsm-profile=desktop',
      '--jsm-runtime-token=0123456789abcdef0123456789abcdef',
    ]);

    expect(config, isNotNull);
    expect(config!.apiBaseUrl, 'http://127.0.0.1:43127/api/v1');
    expect(config.apiReadyUri.toString(), 'http://127.0.0.1:43127/ready');
    expect(
      config.ssoCallbackUri.toString(),
      'http://localhost:43128/auth/callback',
    );
    expect(config.localRuntimeHeaders, {
      'X-JSM-Runtime-Token': '0123456789abcdef0123456789abcdef',
    });
  });

  test('native runtime values take precedence over bundled dotenv values', () {
    final config = DesktopRuntimeConfig.fromArgs([
      '--jsm-api-base-url=http://localhost:44001/api/v1',
      '--jsm-api-port=44001',
      '--jsm-sso-callback-port=44002',
      '--jsm-profile=desktop',
      '--jsm-runtime-token=0123456789abcdef',
    ])!;

    ApiEndpoints.configureRuntime(config);

    expect(ApiEndpoints.baseUrl, 'http://localhost:44001/api/v1');
    expect(ApiEndpoints.ssoRedirectUri, 'http://localhost:44002/auth/callback');
    expect(ApiEndpoints.ssoIssuer, 'http://localhost:3001');
  });

  test('rejects incomplete, malformed, or colliding runtime values', () {
    expect(
      () => DesktopRuntimeConfig.fromArgs(['--jsm-api-port=44001']),
      throwsFormatException,
    );
    expect(
      () => DesktopRuntimeConfig.fromArgs([
        '--jsm-api-base-url=https://example.com:44001/api/v1',
        '--jsm-api-port=44001',
        '--jsm-sso-callback-port=44002',
        '--jsm-profile=desktop',
        '--jsm-runtime-token=0123456789abcdef',
      ]),
      throwsFormatException,
    );
    expect(
      () => DesktopRuntimeConfig.fromArgs([
        '--jsm-api-base-url=http://127.0.0.1:44001/api/v1',
        '--jsm-api-port=44001',
        '--jsm-sso-callback-port=44001',
        '--jsm-profile=desktop',
        '--jsm-runtime-token=0123456789abcdef',
      ]),
      throwsFormatException,
    );
  });
}
