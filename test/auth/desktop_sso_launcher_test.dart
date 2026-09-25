import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jsm_fe/core/errors/exceptions.dart';
import 'package:jsm_fe/features/auth/data/datasources/desktop_sso_launcher.dart';
import 'package:jsm_fe/features/auth/data/datasources/oidc_api_client.dart';
import 'package:jsm_fe/features/auth/data/datasources/sso_session_store.dart';
import 'package:jsm_fe/features/auth/data/datasources/sso_session_store_io.dart';
import 'package:jsm_fe/features/auth/domain/entities/auth_provider.dart';
import 'package:jsm_fe/features/auth/domain/usecases/auth_launcher.dart';

class _MockBrowserSession implements DesktopBrowserSession {
  final Completer<int> exitCompleter = Completer<int>();
  bool terminated = false;
  final bool terminable;

  _MockBrowserSession({this.terminable = true});

  @override
  bool get canTerminate => terminable && !terminated;

  @override
  Future<void> terminate() async {
    terminated = true;
  }

  @override
  Future<int>? get onExit => exitCompleter.future;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;
  const testPort = 5999;

  OidcApiClient createMockApiClient() {
    return OidcApiClient(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/oidc/token')) {
          return http.Response(
            jsonEncode({
              'access_token': 'at-test-token',
              'token_type': 'Bearer',
              'expires_in': 3600,
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'sub': 'sub-9',
            'email': 'user@jsm.dev',
            'name': 'Test User',
          }),
          200,
        );
      }),
    );
  }

  test('desktop flow: browser redirect lands on loopback /auth/callback and completes the token exchange', () async {
    final launcher = DesktopSsoLauncher(
      listenPort: testPort,
      browserLauncher: (_) async => true,
      apiClient: createMockApiClient(),
      terminationDelay: Duration.zero,
    );

    await launcher.start(AuthProvider.web);

    // Extract the dynamically generated state
    final pendingRaw = launcher.store.read(SsoSessionKeys.pendingRequest);
    expect(pendingRaw, isNotNull);
    final pending = jsonDecode(pendingRaw!) as Map<String, dynamic>;
    final state = pending['state'] as String;

    // Simulate the SSO server redirecting the user's browser back.
    final client = HttpClient();
    final request = await client.getUrl(
      Uri.parse('http://localhost:$testPort/auth/callback?code=c1&state=$state'),
    );
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    client.close();

    // Verify response page contains auto-close elements
    expect(body, contains('Đăng nhập thành công'));
    expect(body, contains('window.close();'));
    expect(body, contains('Đóng cửa sổ này'));

    final result = await launcher.awaitCallbackAndComplete();
    expect(result.user.sub, 'sub-9');
    expect(result.user.email, 'user@jsm.dev');

    launcher.clearSession();
  });

  test('desktop flow: wrong-state callback fails safely', () async {
    final launcher = DesktopSsoLauncher(
      listenPort: testPort,
      browserLauncher: (_) async => true,
      apiClient: OidcApiClient(
        client: MockClient(
          (request) async => fail('exchange must not run on bad state'),
        ),
      ),
      terminationDelay: Duration.zero,
    );
    await launcher.start(AuthProvider.web);

    final client = HttpClient();
    final request = await client.getUrl(
      Uri.parse('http://localhost:$testPort/auth/callback?code=c1&state=evil'),
    );
    await (await request.close()).drain<void>();
    client.close();

    await expectLater(
      launcher.awaitCallbackAndComplete(),
      throwsA(isA<ServerException>()),
    );
    launcher.clearSession();
  });

  test('browser launcher lifecycle completes and terminates browser session upon successful callback', () async {
    final session = _MockBrowserSession(terminable: true);
    final launcher = DesktopSsoLauncher(
      listenPort: testPort,
      sessionLauncher: (_) async => session,
      apiClient: createMockApiClient(),
      terminationDelay: Duration.zero,
    );

    await launcher.start(AuthProvider.web);
    expect(session.terminated, isFalse);

    final pendingRaw = launcher.store.read(SsoSessionKeys.pendingRequest);
    final pending = jsonDecode(pendingRaw!) as Map<String, dynamic>;
    final state = pending['state'] as String;

    final client = HttpClient();
    final request = await client.getUrl(
      Uri.parse('http://localhost:$testPort/auth/callback?code=code123&state=$state'),
    );
    final response = await request.close();
    await response.drain<void>();
    client.close();

    final result = await launcher.awaitCallbackAndComplete();
    expect(result.user.sub, 'sub-9');
    expect(session.terminated, isTrue);
    expect(launcher.loopbackServerRunning, isFalse);

    launcher.clearSession();
  });

  test('cancellation: user closing the browser window triggers cancellation error', () async {
    final session = _MockBrowserSession(terminable: true);
    final launcher = DesktopSsoLauncher(
      listenPort: testPort,
      sessionLauncher: (_) async => session,
      apiClient: createMockApiClient(),
      terminationDelay: Duration.zero,
    );

    await launcher.start(AuthProvider.web);

    // Simulate user closing the window before authenticating
    session.exitCompleter.complete(0);
    // Allow microtask to process exitCode
    await Future<void>.delayed(const Duration(milliseconds: 10));

    await expectLater(
      launcher.awaitCallbackAndComplete(),
      throwsA(
        isA<AuthLauncherException>().having(
          (e) => e.message,
          'message',
          contains('Login window was closed by the user'),
        ),
      ),
    );
    expect(launcher.loopbackServerRunning, isFalse);
    launcher.clearSession();
  });

  test('cancellation: explicit clearSession cancels pending callback and terminates browser', () async {
    final session = _MockBrowserSession(terminable: true);
    final launcher = DesktopSsoLauncher(
      listenPort: testPort,
      sessionLauncher: (_) async => session,
      apiClient: createMockApiClient(),
      terminationDelay: Duration.zero,
    );

    await launcher.start(AuthProvider.web);
    expect(launcher.loopbackServerRunning, isTrue);

    launcher.clearSession();
    expect(session.terminated, isTrue);
    expect(launcher.loopbackServerRunning, isFalse);

    await expectLater(
      launcher.awaitCallbackAndComplete(),
      throwsA(
        isA<AuthLauncherException>().having(
          (e) => e.message,
          'message',
          contains('Login cancelled'),
        ),
      ),
    );
  });

  test('callback error: OAuth error parameter (?error=access_denied) serves error HTML and throws AuthLauncherException', () async {
    final session = _MockBrowserSession(terminable: true);
    final launcher = DesktopSsoLauncher(
      listenPort: testPort,
      sessionLauncher: (_) async => session,
      apiClient: createMockApiClient(),
      terminationDelay: Duration.zero,
    );

    await launcher.start(AuthProvider.web);

    final client = HttpClient();
    final request = await client.getUrl(
      Uri.parse('http://localhost:$testPort/auth/callback?error=access_denied&error_description=User+denied+consent'),
    );
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    client.close();

    // Verify response page contains error indication and close button
    expect(body, contains('Đăng nhập không thành công'));
    expect(body, contains('User denied consent'));
    expect(body, contains('Đóng cửa sổ này'));

    await expectLater(
      launcher.awaitCallbackAndComplete(),
      throwsA(
        isA<AuthLauncherException>().having(
          (e) => e.message,
          'message',
          contains('User denied consent'),
        ),
      ),
    );

    expect(session.terminated, isTrue);
    expect(launcher.loopbackServerRunning, isFalse);
    launcher.clearSession();
  });

  test('unsupported platform fallback: returns error and cleans up server when launcher returns null', () async {
    final launcher = DesktopSsoLauncher(
      listenPort: testPort,
      sessionLauncher: (_) async => null, // simulates platform where browser launch is unsupported/fails
      apiClient: createMockApiClient(),
      terminationDelay: Duration.zero,
    );

    await expectLater(
      launcher.start(AuthProvider.web),
      throwsA(
        isA<AuthLauncherException>().having(
          (e) => e.message,
          'message',
          contains('Could not launch the login window'),
        ),
      ),
    );

    expect(launcher.loopbackServerRunning, isFalse);
    launcher.clearSession();
  });

  test('no duplicate browser launch: start while in flight throws and does not launch second session', () async {
    int launchCount = 0;
    final session = _MockBrowserSession(terminable: true);
    final launcher = DesktopSsoLauncher(
      listenPort: testPort,
      sessionLauncher: (_) async {
        launchCount++;
        return session;
      },
      apiClient: createMockApiClient(),
      terminationDelay: Duration.zero,
    );

    await launcher.start(AuthProvider.web);
    expect(launchCount, 1);

    // Second start attempt while first is in flight
    await expectLater(
      launcher.start(AuthProvider.web),
      throwsA(
        isA<AuthLauncherException>().having(
          (e) => e.message,
          'message',
          contains('Login is already in progress'),
        ),
      ),
    );

    // Launch count must still be 1
    expect(launchCount, 1);
    launcher.clearSession();
  });

  test('authenticated state after callback stores tokens and user in session store', () async {
    final store = MemorySsoSessionStore();
    final session = _MockBrowserSession(terminable: true);
    final launcher = DesktopSsoLauncher(
      listenPort: testPort,
      store: store,
      sessionLauncher: (_) async => session,
      apiClient: createMockApiClient(),
      terminationDelay: Duration.zero,
    );

    await launcher.start(AuthProvider.web);

    final pendingRaw = store.read(SsoSessionKeys.pendingRequest);
    final pending = jsonDecode(pendingRaw!) as Map<String, dynamic>;
    final state = pending['state'] as String;

    final client = HttpClient();
    final request = await client.getUrl(
      Uri.parse('http://localhost:$testPort/auth/callback?code=c1&state=$state'),
    );
    await (await request.close()).drain<void>();
    client.close();

    final result = await launcher.awaitCallbackAndComplete();
    expect(result.user.email, 'user@jsm.dev');

    // Stored tokens and user verified
    expect(store.read(SsoSessionKeys.tokens), contains('at-test-token'));
    expect(store.read(SsoSessionKeys.user), contains('user@jsm.dev'));

    launcher.clearSession();
  });
}
