class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';

  // Auth
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  // Journals / Publications
  static const String journals = '$baseUrl/journals';
  static const String publicationTrends = '$baseUrl/trends';
}
