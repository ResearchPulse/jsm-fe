import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jsm_fe/core/errors/exceptions.dart';
import 'package:jsm_fe/features/auth/data/datasources/oidc_api_client.dart';

Map<String, dynamic> _tokenBody() => {
      'access_token': 'at-secret-value',
      'token_type': 'Bearer',
      'expires_in': 3600,
      'refresh_token': 'rt-secret-value',
      'id_token': 'it-secret-value',
    };

Map<String, dynamic> _userBody() => {
      'sub': 'user-1',
      'email': 'user@example.com',
      'name': 'Example User',
      'picture': 'https://cdn.example.com/avatar.png',
    };

http.Response _json(Object body, [int status = 200]) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

void main() {
  group('exchangeCode', () {
    test('success: posts correct JSON, maps full token response', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return _json(_tokenBody());
      });
      final api = OidcApiClient(client: client);

      final tokens = await api.exchangeCode(
        code: 'the-code',
        redirectUri: 'http://localhost:3003/auth/callback',
        codeVerifier: 'the-verifier',
      );

      expect(captured.url.toString(),
          'http://localhost:3001/api/v1/oidc/token');
      expect(captured.method, 'POST');
      expect(
          jsonDecode(captured.body),
          {
            'grant_type': 'authorization_code',
            'client_id': 'researchpulse-ecosystem',
            'code': 'the-code',
            'redirect_uri': 'http://localhost:3003/auth/callback',
            'code_verifier': 'the-verifier',
          });
      expect(tokens.accessToken, 'at-secret-value');
      expect(tokens.refreshToken, 'rt-secret-value');
      expect(tokens.idToken, 'it-secret-value');
      expect(tokens.expiresAtMs, isNotNull);
      expect(tokens.isExpired, isFalse);
    });

    test('failure: non-200 status throws ServerException', () async {
      final client = MockClient(
          (request) async => _json({'error': 'invalid_grant'}, 400));
      final api = OidcApiClient(client: client);
      await expectLater(
        api.exchangeCode(
            code: 'c', redirectUri: 'r', codeVerifier: 'v'),
        throwsA(isA<ServerException>()),
      );
    });

    test('failure: missing access_token throws ServerException', () async {
      final client = MockClient((request) async => _json({'nope': 1}));
      final api = OidcApiClient(client: client);
      await expectLater(
        api.exchangeCode(
            code: 'c', redirectUri: 'r', codeVerifier: 'v'),
        throwsA(isA<ServerException>()),
      );
    });

    test('failure: network error throws NetworkException', () async {
      final client = MockClient((request) async => throw Exception('offline'));
      final api = OidcApiClient(client: client);
      await expectLater(
        api.exchangeCode(
            code: 'c', redirectUri: 'r', codeVerifier: 'v'),
        throwsA(isA<NetworkException>()),
      );
    });
  });

  group('fetchUserInfo', () {
    test('success: bearer header sent, sub/email/name/picture mapped',
        () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return _json(_userBody());
      });
      final api = OidcApiClient(client: client);

      final user = await api.fetchUserInfo('at-secret-value');

      expect(captured.url.toString(),
          'http://localhost:3001/api/v1/oidc/userinfo');
      expect(captured.headers['Authorization'], 'Bearer at-secret-value');
      expect(user.sub, 'user-1');
      expect(user.email, 'user@example.com');
      expect(user.name, 'Example User');
      expect(user.picture, 'https://cdn.example.com/avatar.png');
    });

    test('failure: 401 throws ServerException', () async {
      final client = MockClient((request) async => _json({}, 401));
      final api = OidcApiClient(client: client);
      await expectLater(
        api.fetchUserInfo('bad'),
        throwsA(isA<ServerException>()),
      );
    });

    test('failure: malformed JSON throws ServerException', () async {
      final client = MockClient(
          (request) async => http.Response('not-json', 200));
      final api = OidcApiClient(client: client);
      await expectLater(
        api.fetchUserInfo('ok'),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
