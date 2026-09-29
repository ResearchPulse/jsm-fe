import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/core/runtime/desktop_runtime_config.dart';

void main() {
  test('Dart sidecar seam exposes native readiness and callback contracts', () {
    final config = DesktopRuntimeConfig.fromArgs([
      '--jsm-api-base-url=http://127.0.0.1:45001/api/v1',
      '--jsm-api-port=45001',
      '--jsm-sso-callback-port=45002',
      '--jsm-profile=desktop',
      '--jsm-runtime-token=0123456789abcdef',
    ])!;

    expect(config.apiReadyUri.path, '/ready');
    expect(config.apiReadyUri.port, 45001);
    expect(config.ssoCallbackUri.path, '/auth/callback');
    expect(config.ssoCallbackUri.port, 45002);
    expect(
      config.localRuntimeHeaders.keys,
      contains(DesktopRuntimeConfig.runtimeTokenHeader),
    );
  });
}
