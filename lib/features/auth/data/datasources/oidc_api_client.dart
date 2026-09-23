import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';

/// Token payload from POST /api/v1/oidc/token. Tokens are never logged or
/// shown in UI; they stay in the session store and this data class.
class SsoTokens {
  final String accessToken;
  final String? refreshToken;
  final String? idToken;

  /// Epoch milliseconds when [accessToken] expires.
  final int? expiresAtMs;

  const SsoTokens({
    required this.accessToken,
    this.refreshToken,
    this.idToken,
    this.expiresAtMs,
  });

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        if (refreshToken != null) 'refresh_token': refreshToken,
        if (idToken != null) 'id_token': idToken,
        if (expiresAtMs != null) 'expires_at': expiresAtMs,
      };

  factory SsoTokens.fromJson(Map<String, dynamic> json) => SsoTokens(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String?,
        idToken: json['id_token'] as String?,
        expiresAtMs: json['expires_at'] as int?,
      );

  bool get isExpired =>
      expiresAtMs != null &&
      DateTime.now().millisecondsSinceEpoch >= expiresAtMs!;
}

/// OIDC userinfo profile from GET /api/v1/oidc/userinfo.
class SsoUserInfo {
  final String sub;
  final String? email;
  final String? name;
  final String? picture;

  const SsoUserInfo({
    required this.sub,
    this.email,
    this.name,
    this.picture,
  });

  Map<String, dynamic> toJson() => {
        'sub': sub,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
        if (picture != null) 'picture': picture,
      };

  factory SsoUserInfo.fromJson(Map<String, dynamic> json) => SsoUserInfo(
        sub: json['sub'] as String,
        email: json['email'] as String?,
        name: json['name'] as String?,
        picture: json['picture'] as String?,
      );
}

/// HTTP client for the Central SSO token and userinfo endpoints. The
/// [Client] is injected so tests can mock the network.
class OidcApiClient {
  final http.Client _client;

  OidcApiClient({http.Client? client})
      : _client = client ?? http.Client();

  /// Exchanges the authorization code (Authorization Code + PKCE flow).
  Future<SsoTokens> exchangeCode({
    required String code,
    required String redirectUri,
    required String codeVerifier,
  }) async {
    final uri =
        Uri.parse('${ApiEndpoints.ssoIssuer}/api/v1/oidc/token');
    http.Response response;
    try {
      response = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'grant_type': 'authorization_code',
          'client_id': ApiEndpoints.ssoClientId,
          'code': code,
          'redirect_uri': redirectUri,
          'code_verifier': codeVerifier,
        }),
      );
    } catch (e) {
      throw NetworkException('Could not reach the login server.');
    }
    if (response.statusCode != 200) {
      throw const ServerException('Login was rejected by the login server.');
    }
    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw const ServerException('Malformed login server response.');
    }
    final accessToken = body['access_token'];
    if (accessToken is! String || accessToken.isEmpty) {
      throw const ServerException('Login response is missing a token.');
    }
    final expiresIn = body['expires_in'];
    return SsoTokens(
      accessToken: accessToken,
      refreshToken: body['refresh_token'] as String?,
      idToken: body['id_token'] as String?,
      expiresAtMs: expiresIn is num
          ? DateTime.now().millisecondsSinceEpoch +
              (expiresIn * 1000).round()
          : null,
    );
  }

  /// Fetches the canonical user profile.
  Future<SsoUserInfo> fetchUserInfo(String accessToken) async {
    final uri =
        Uri.parse('${ApiEndpoints.ssoIssuer}/api/v1/oidc/userinfo');
    http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (e) {
      throw NetworkException('Could not reach the login server.');
    }
    if (response.statusCode != 200) {
      throw const ServerException('Could not load the user profile.');
    }
    try {
      return SsoUserInfo.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } catch (_) {
      throw const ServerException('Malformed user profile response.');
    }
  }
}
