import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../runtime/desktop_runtime_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static DesktopRuntimeConfig? _runtimeConfig;

  /// Installs the one-launch desktop values negotiated by the native runner.
  /// This must happen before `.env` is loaded so bundled values cannot win.
  static void configureRuntime(DesktopRuntimeConfig config) {
    _runtimeConfig = config;
  }

  /// Test-only seam for resetting the process-global desktop contract.
  static void clearRuntime() {
    _runtimeConfig = null;
  }

  static String? _getEnv(String key) {
    if (dotenv.isInitialized) {
      return dotenv.maybeGet(key);
    }
    return null;
  }

  static String get baseUrl =>
      _runtimeConfig?.apiBaseUrl ??
      _getEnv('API_BASE_URL') ??
      const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'http://127.0.0.1:8000/api/v1',
      );

  // Auth
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';

  // Journals / Publications
  static String get journals => '$baseUrl/journals';
  static String get publicationTrends => '$baseUrl/trends';

  // Central SSO (OIDC). Issuer/client id are public identifiers (no secret
  // is ever shipped in the client). Loaded from .env or --dart-define. The
  // issuer remains separate from the loopback API negotiated above.
  static String get ssoIssuer =>
      _getEnv('SSO_ISSUER_URL') ??
      const String.fromEnvironment(
        'SSO_ISSUER_URL',
        defaultValue: 'http://localhost:3001',
      );

  static String get ssoClientId =>
      _getEnv('SSO_CLIENT_ID') ??
      const String.fromEnvironment(
        'SSO_CLIENT_ID',
        defaultValue: 'researchpulse-ecosystem',
      );

  static String get ssoRedirectUri =>
      _runtimeConfig?.ssoCallbackUri.toString() ??
      _getEnv('SSO_REDIRECT_URI') ??
      const String.fromEnvironment(
        'SSO_REDIRECT_URI',
        defaultValue: 'http://localhost:5173/auth/callback',
      );

  static Map<String, String> get localRuntimeHeaders =>
      _runtimeConfig?.localRuntimeHeaders ?? const <String, String>{};

  // Users (admin account management; BE users module contract).
  static String get users => '$baseUrl/users';

  // Student Manuscript Checker
  static String get studentManuscriptCheck =>
      '$baseUrl/student/manuscript/check';
  static String get studentManuscriptCheckStream =>
      '$baseUrl/student/manuscript/check-stream';
  static String get studentAvailableJournals =>
      '$baseUrl/student/available-journals';
  static String get studentEvaluations => '$baseUrl/student/evaluations';
  static String get studentEvaluationHistory =>
      '$baseUrl/student/evaluations/history';
  static String get studentEvaluationStats =>
      '$baseUrl/student/evaluations/stats';
  static String get studentRecommendations =>
      '$baseUrl/student/recommendations';

  // Admin Module Endpoints
  static String get adminJournals => '$baseUrl/admin/journals';
  static String get adminOpenAlexJournals => '$baseUrl/admin/journals/openalex';
  static String get adminImportJournal => '$baseUrl/admin/journals/import';
  static String get adminConfigurations => '$baseUrl/admin/configurations';
  static String get adminAnalysisJobs => '$baseUrl/admin/analysis-jobs';
  static String get adminSnapshots => '$baseUrl/admin/snapshots';
  static String get adminStyleProfiles => '$baseUrl/admin/style-profiles';
  static String get monitorStats => '$baseUrl/monitor/stats';
  static String get systemHealth {
    final uri = Uri.parse(baseUrl);
    return uri.replace(path: '/health', query: null, fragment: null).toString();
  }
}
