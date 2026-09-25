import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/auth_provider.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/usecases/auth_launcher.dart';
import 'browser_sso_seam.dart';
import 'oidc_auth.dart';
import 'sso_auth_launcher.dart';
import 'sso_session_store.dart';
import 'sso_session_store_io.dart';

typedef BrowserLauncher = Future<bool> Function(String url);
typedef DesktopSessionLauncher = Future<DesktopBrowserSession?> Function(String url);

/// Represents an active desktop browser session launched for authentication.
abstract class DesktopBrowserSession {
  /// Whether this session is backed by a process that can be programmatically terminated.
  bool get canTerminate;

  /// Terminates the browser window/session cleanly.
  Future<void> terminate();

  /// Completes when the browser process exits (e.g. user manually closed the window).
  /// Null if not backed by a trackable process.
  Future<int>? get onExit;
}

/// A desktop browser session backed by an isolated OS process (e.g. Edge or Chrome in app mode).
class DesktopProcessBrowserSession implements DesktopBrowserSession {
  final Process process;
  final Directory? tempProfileDir;
  bool _terminated = false;

  DesktopProcessBrowserSession({
    required this.process,
    this.tempProfileDir,
  });

  @override
  bool get canTerminate => !_terminated;

  @override
  Future<int> get onExit => process.exitCode;

  @override
  Future<void> terminate() async {
    if (_terminated) return;
    _terminated = true;

    try {
      process.kill();
    } catch (_) {}

    // On Windows, also kill any child processes in this process tree to ensure
    // no orphan renderer/utility processes remain, without touching any unrelated browser.
    if (Platform.isWindows) {
      try {
        await Process.run('taskkill', ['/pid', '${process.pid}', '/T', '/F']);
      } catch (_) {}
    }

    if (tempProfileDir != null) {
      // Delay slightly before deleting directory to allow process file locks to be released.
      Future<void>.delayed(const Duration(milliseconds: 500), () {
        try {
          if (tempProfileDir!.existsSync()) {
            tempProfileDir!.deleteSync(recursive: true);
          }
        } catch (_) {}
      });
    }
  }
}

/// A fallback browser session (e.g. rundll32, xdg-open, open) that cannot be terminated
/// programmatically without affecting unrelated browser tabs.
class NonTerminableBrowserSession implements DesktopBrowserSession {
  const NonTerminableBrowserSession();

  @override
  bool get canTerminate => false;

  @override
  Future<void> terminate() async {}

  @override
  Future<int>? get onExit => null;
}

/// Launches the browser on Desktop platforms using pure dart:io (no native plugin needed).
/// On Windows, it attempts to launch Edge or Chrome in an isolated app window for a clean
/// embedded-window appearance that can be naturally terminated when auth completes.
Future<DesktopBrowserSession?> defaultDesktopBrowserSessionLauncher(String url) async {
  if (Platform.isWindows) {
    // 1. Try launching Microsoft Edge or Google Chrome in dedicated app mode with an isolated profile
    const browserCandidates = [
      r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
      r'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
      'msedge.exe',
      r'C:\Program Files\Google\Chrome\Application\chrome.exe',
      r'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
      'chrome.exe',
    ];

    for (final exe in browserCandidates) {
      try {
        final isNamedExe = !exe.contains(r'\');
        if (isNamedExe || File(exe).existsSync()) {
          final tempDir = Directory.systemTemp.createTempSync('jsm_auth_');
          final process = await Process.start(exe, [
            '--user-data-dir=${tempDir.path}',
            '--no-first-run',
            '--no-default-browser-check',
            '--app=$url',
            '--window-size=520,720',
          ]);
          return DesktopProcessBrowserSession(
            process: process,
            tempProfileDir: tempDir,
          );
        }
      } catch (_) {}
    }

    // 2. Fallback to rundll32 url.dll,FileProtocolHandler (preserves '&' and query parameters)
    try {
      final res = await Process.run('rundll32', ['url.dll,FileProtocolHandler', url]);
      if (res.exitCode == 0) return const NonTerminableBrowserSession();
    } catch (_) {}

    // 3. Fallback to cmd.exe start with properly escaped ampersands (^&)
    try {
      final escapedUrl = url.replaceAll('&', '^&');
      final res = await Process.run('cmd.exe', ['/c', 'start', '', escapedUrl]);
      if (res.exitCode == 0) return const NonTerminableBrowserSession();
    } catch (_) {}

    return null;
  } else if (Platform.isMacOS) {
    try {
      final res = await Process.run('open', [url]);
      if (res.exitCode == 0) return const NonTerminableBrowserSession();
    } catch (_) {}
    return null;
  } else if (Platform.isLinux) {
    try {
      final res = await Process.run('xdg-open', [url]);
      if (res.exitCode == 0) return const NonTerminableBrowserSession();
    } catch (_) {}
    return null;
  }
  return null;
}

/// Backwards-compatible boolean launcher wrapping [defaultDesktopBrowserSessionLauncher].
Future<bool> defaultDesktopBrowserLauncher(String url) async {
  final session = await defaultDesktopBrowserSessionLauncher(url);
  return session != null;
}

enum BrowserCallbackStatus {
  success,
  failure,
  waiting,
}

/// Desktop implementation of the Central SSO flow:
/// 1. builds the same PKCE/S256 authorize URL as the web launcher,
/// 2. opens the user's browser in standalone app mode with an isolated profile,
/// 3. runs a one-shot loopback HTTP server on localhost:5173 that receives
///    the SSO redirect at /auth/callback (the configured SSO_REDIRECT_URI),
/// 4. completes the token exchange + userinfo with the shared launcher code,
/// 5. naturally terminates the isolated browser session upon success/cancel.
class DesktopSsoLauncher extends SsoAuthLauncher {
  final int listenPort;
  final DesktopSessionLauncher sessionLauncher;
  final Duration terminationDelay;

  DesktopSsoLauncher({
    int? listenPort,
    super.apiClient,
    SsoSessionStore? store,
    BrowserLauncher? browserLauncher,
    DesktopSessionLauncher? sessionLauncher,
    Duration? terminationDelay,
  })  : listenPort = listenPort ?? _defaultPort(),
        sessionLauncher = sessionLauncher ??
            (browserLauncher != null
                ? ((url) async {
                    final ok = await browserLauncher(url);
                    return ok ? const NonTerminableBrowserSession() : null;
                  })
                : defaultDesktopBrowserSessionLauncher),
        terminationDelay =
            terminationDelay ?? const Duration(milliseconds: 600),
        super(store: store ?? MemorySsoSessionStore());

  static int _defaultPort() {
    final configured = Uri.tryParse(ApiEndpoints.ssoRedirectUri)?.port;
    if (configured != null && configured > 0) return configured;
    return 5173;
  }

  BrowserLauncher get browserLauncher => (url) async {
        final session = await sessionLauncher(url);
        return session != null;
      };

  HttpServer? _server;
  Completer<Uri>? _callback;
  DesktopBrowserSession? _currentSession;
  bool _isCompleting = false;
  bool _inFlight = false;

  @override
  Future<void> start(AuthProvider provider) async {
    if (_inFlight) {
      throw const AuthLauncherException('Login is already in progress.');
    }
    _inFlight = true;
    _isCompleting = false;
    _callback = Completer<Uri>();
    _callback!.future.ignore();

    try {
      await _startLoopbackServer();
      final redirectUri = 'http://localhost:$listenPort/auth/callback';
      final pending = OidcAuthUrlBuilder.createPendingRequest();
      store.write(
        SsoSessionKeys.pendingRequest,
        jsonEncode({
          'state': pending.state,
          'code_verifier': pending.codeVerifier,
          'redirect_uri': redirectUri,
        }),
      );
      final url = urlBuilder.build(
        provider: provider,
        redirectUri: redirectUri,
        state: pending.state,
        codeChallenge:
            OidcAuthUrlBuilder.createCodeChallenge(pending.codeVerifier),
      );

      final session = await sessionLauncher(url);
      if (session == null) {
        throw const AuthLauncherException('Could not launch the login window.');
      }
      _currentSession = session;

      // Monitor browser exit: if user manually closes the window before callback arrives
      session.onExit?.then((exitCode) {
        if (!_isCompleting && (_callback != null && !_callback!.isCompleted)) {
          _callback!.completeError(
            const AuthLauncherException('Login window was closed by the user.'),
          );
        }
      });
    } catch (e) {
      _inFlight = false;
      await _server?.close(force: true);
      _server = null;
      await _currentSession?.terminate();
      _currentSession = null;
      rethrow;
    }
  }

  /// Waits for the browser redirect, then completes the SSO exchange.
  Future<AuthResult> awaitCallbackAndComplete({
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final completer = _callback;
    if (completer == null) {
      throw const AuthLauncherException('No login in progress.');
    }
    try {
      final uri = await completer.future.timeout(
        timeout,
        onTimeout: () => throw const AuthLauncherException(
          'Login timed out. Please try again.',
        ),
      );
      return await completeFromLoopbackCallback(uri);
    } catch (e) {
      clearSession();
      rethrow;
    }
  }

  Future<void> _startLoopbackServer() async {
    if (_server != null) return;
    try {
      _server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        listenPort,
      );
    } on SocketException {
      if (_server != null) return;
      throw AuthLauncherException(
        'Port $listenPort is already in use. Close other apps and retry.',
      );
    }

    _server!.listen((request) async {
      if (request.uri.path == '/favicon.ico') {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final uri = Uri.parse('http://localhost:$listenPort${request.uri}');
      final isCallback = uri.path == AppConstants.ssoCallbackPath;

      if (!isCallback) {
        await _respondBrowserPage(
          request,
          status: BrowserCallbackStatus.waiting,
        );
        return;
      }

      // Check for error parameters in the callback redirect
      final hasError = uri.queryParameters.containsKey('error');
      final errorDescription = uri.queryParameters['error_description'] ??
          uri.queryParameters['error'];
      final hasCode = uri.queryParameters.containsKey('code');

      if (hasError || !hasCode) {
        await _respondBrowserPage(
          request,
          status: BrowserCallbackStatus.failure,
          errorMessage: errorDescription ?? 'Authentication was cancelled or failed.',
        );
        if (_callback != null && !_callback!.isCompleted) {
          _callback!.completeError(
            AuthLauncherException(
              errorDescription ?? 'Authentication was cancelled or failed.',
            ),
          );
        }
        return;
      }

      // Success callback
      final responded = _respondBrowserPage(
        request,
        status: BrowserCallbackStatus.success,
      );
      if (_callback != null && !_callback!.isCompleted) {
        _callback!.complete(uri);
      }
      await responded;
    });
  }

  /// Same completion logic as the web flow, but against an arbitrary loopback
  /// URI instead of the browser's current page.
  Future<AuthResult> completeFromLoopbackCallback(Uri uri) async {
    _isCompleting = true;
    await _server?.close();
    _server = null;

    BrowserSso.currentUri = () => uri;
    BrowserSso.redirectUri =
        () => 'http://localhost:$listenPort/auth/callback';
    BrowserSso.cleanHistory = () {};

    try {
      final result = await completeFromCallback();
      _inFlight = false;
      _scheduleBrowserTermination();
      return result;
    } catch (e) {
      _inFlight = false;
      await _currentSession?.terminate();
      _currentSession = null;
      rethrow;
    } finally {
      BrowserSso.resetToDefaults();
    }
  }

  void _scheduleBrowserTermination() {
    final session = _currentSession;
    _currentSession = null;
    if (session != null && session.canTerminate) {
      if (terminationDelay == Duration.zero) {
        session.terminate();
      } else {
        Future<void>.delayed(terminationDelay, () async {
          await session.terminate();
        });
      }
    }
  }

  /// Raw socket requests bypass TestWidgetsFlutterBinding's HTTP mock, so
  /// tests must opt out of the binding before using the loopback server.
  bool get loopbackServerRunning => _server != null;

  String _htmlEscape(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  String _buildPageHtml({
    required BrowserCallbackStatus status,
    String? errorMessage,
  }) {
    final isSuccess = status == BrowserCallbackStatus.success;
    final isFailure = status == BrowserCallbackStatus.failure;

    final title = isSuccess
        ? 'Đăng nhập thành công'
        : isFailure
            ? 'Đăng nhập không thành công'
            : 'Đang xử lý đăng nhập';

    final icon = isSuccess ? '&#10004;' : (isFailure ? '&#10006;' : '&#8987;');
    final iconBg = isSuccess ? '#ecfdf5' : (isFailure ? '#fef2f2' : '#f1f5f9');
    final iconColor = isSuccess ? '#059669' : (isFailure ? '#dc2626' : '#64748b');

    final heading = isSuccess
        ? 'Đăng nhập thành công'
        : isFailure
            ? 'Đăng nhập không thành công'
            : 'Đang chờ đăng nhập...';

    final message = isSuccess
        ? 'Cửa sổ này sẽ tự động đóng và quay lại ứng dụng Journal Style Miner.'
        : isFailure
            ? _htmlEscape(errorMessage ?? 'Quá trình đăng nhập đã bị hủy hoặc xảy ra lỗi.')
            : 'Vui lòng hoàn tất quá trình xác thực trên trình duyệt.';

    final autoCloseScript = isSuccess
        ? '''
<script>
function closeWindow() {
  try {
    window.open('', '_self', '');
    window.close();
  } catch (e) {}
  try {
    window.close();
  } catch (e) {}
}
closeWindow();
setTimeout(closeWindow, 600);
setTimeout(function() {
  var msg = document.getElementById('msg');
  if (msg) {
    msg.textContent = 'Bạn đã hoàn tất đăng nhập! Vui lòng quay lại ứng dụng Journal Style Miner.';
  }
}, 1200);
</script>
'''
        : '';

    final buttonHtml = (isSuccess || isFailure)
        ? '<button class="btn" onclick="try{window.open(\'\',\'_self\',\'\');window.close();}catch(e){}try{window.close();}catch(e){}">Đóng cửa sổ này</button>'
        : '';

    final hintHtml = isSuccess
        ? '<div class="hint">Nếu cửa sổ không tự đóng, bạn có thể bấm nút trên hoặc đóng tab này thủ công.</div>'
        : isFailure
            ? '<div class="hint">Bạn có thể đóng tab này và thử đăng nhập lại trong ứng dụng.</div>'
            : '';

    return '''<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>$title</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
      background: #f8fafc;
      color: #1e293b;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      margin: 0;
      padding: 24px;
      box-sizing: border-box;
    }
    .card {
      background: #ffffff;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      padding: 40px 32px;
      max-width: 440px;
      width: 100%;
      text-align: center;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
    }
    .icon {
      width: 56px;
      height: 56px;
      line-height: 56px;
      background: $iconBg;
      color: $iconColor;
      font-size: 28px;
      border-radius: 50%;
      margin: 0 auto 20px;
      display: inline-block;
    }
    h2 {
      margin: 0 0 12px;
      font-size: 20px;
      font-weight: 600;
      color: #0f172a;
    }
    p {
      margin: 0 0 24px;
      font-size: 14px;
      color: #64748b;
      line-height: 1.5;
    }
    .btn {
      display: inline-block;
      background: #2563eb;
      color: #ffffff;
      padding: 10px 24px;
      border-radius: 8px;
      font-size: 14px;
      font-weight: 500;
      border: none;
      cursor: pointer;
      text-decoration: none;
      transition: background 0.15s;
    }
    .btn:hover {
      background: #1d4ed8;
    }
    .hint {
      margin-top: 16px;
      font-size: 12px;
      color: #94a3b8;
    }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">$icon</div>
    <h2>$heading</h2>
    <p id="msg">$message</p>
    $buttonHtml
    $hintHtml
  </div>
  $autoCloseScript
</body>
</html>''';
  }

  Future<void> _respondBrowserPage(
    HttpRequest request, {
    required BrowserCallbackStatus status,
    String? errorMessage,
  }) async {
    request.response.headers.contentType = ContentType.html;
    request.response.headers.set('Cache-Control', 'no-store, no-cache, must-revalidate');
    final html = _buildPageHtml(status: status, errorMessage: errorMessage);
    request.response.write(html);
    await request.response.close();
  }

  @override
  void clearSession() {
    _inFlight = false;
    _isCompleting = false;
    if (_callback != null && !_callback!.isCompleted) {
      _callback!.completeError(
        const AuthLauncherException('Login cancelled.'),
      );
    }
    _server?.close(force: true);
    _server = null;
    _currentSession?.terminate();
    _currentSession = null;
    super.clearSession();
  }
}
