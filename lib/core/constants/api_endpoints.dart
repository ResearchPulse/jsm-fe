import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  ApiEndpoints._();

  static String? _getEnv(String key) {
    if (dotenv.isInitialized) {
      return dotenv.maybeGet(key);
    }
    return null;
  }

  static String get baseUrl =>
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
  // is ever shipped in the client). Loaded from .env or --dart-define.
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
      _getEnv('SSO_REDIRECT_URI') ??
      const String.fromEnvironment(
        'SSO_REDIRECT_URI',
        defaultValue: 'http://localhost:5173/auth/callback',
      );

  // Users (admin account management; BE users module contract).
  static String get users => '$baseUrl/users';

  // Member 2 & Member 3 Pipeline & AI Endpoints
  static String get rhetoricalPredict => '$baseUrl/rhetorical-moves/predict';
  static String get rhetoricalPredictBatch => '$baseUrl/rhetorical-moves/predict-batch';
  static String get rhetoricalInfo => '$baseUrl/rhetorical-moves/info';
  static String get nlpExtractFeatures => '$baseUrl/nlp/extract-features';
  static String get nlpBuildProfile => '$baseUrl/nlp/build-profile';
  static String get monitorStats => '$baseUrl/monitor/stats';
  static String get adminAnalysisJobs => '$baseUrl/admin/analysis-jobs';
  static String get adminJournalConfigurations => '$baseUrl/admin/journal-configurations';
}

