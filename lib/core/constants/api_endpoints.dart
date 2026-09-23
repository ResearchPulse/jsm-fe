class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  // Journals / Publications
  static const String journals = '$baseUrl/journals';
  static const String publicationTrends = '$baseUrl/trends';

  // Central SSO (OIDC). Issuer/client id are public identifiers (no secret
  // is ever shipped in the client). Override per environment via --dart-define
  // when needed; these are the local defaults.
  static const String ssoIssuer = String.fromEnvironment(
    'SSO_ISSUER_URL',
    defaultValue: 'http://localhost:3001',
  );
  static const String ssoClientId = String.fromEnvironment(
    'SSO_CLIENT_ID',
    defaultValue: 'researchpulse-ecosystem',
  );
}
