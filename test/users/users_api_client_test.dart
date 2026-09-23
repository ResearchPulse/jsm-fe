import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jsm_fe/core/errors/exceptions.dart';
import 'package:jsm_fe/features/users/data/datasources/users_api_client.dart';
import 'package:jsm_fe/features/users/domain/entities/user_profile.dart';

http.Response _json(Map<String, dynamic> body, [int status = 201]) =>
    http.Response(jsonEncode(body), status,
        headers: {'content-type': 'application/json'});

void main() {
  group('UsersApiClient', () {
    test('success: posts role/email/full_name/password with bearer token',
        () async {
      Uri? capturedUri;
      Map<String, dynamic>? capturedBody;
      String? capturedAuth;

      final client = UsersApiClient(
        tokenProvider: () async => 'token-123',
        client: MockClient((request) async {
          capturedUri = request.url;
          capturedAuth = request.headers['Authorization'];
          capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return _json({
            'id': 'u9',
            'email': 's@university.edu',
            'full_name': 'Sinh Vien',
          });
        }),
      );

      final user = await client.createAccount(
        role: UserRole.student,
        email: 's@university.edu',
        fullName: 'Sinh Vien',
        password: 'secret-pass-1',
      );

      expect(capturedUri!.toString(), contains('/api/v1/users'));
      expect(capturedAuth, 'Bearer token-123');
      expect(capturedBody, {
        'role': 'student',
        'email': 's@university.edu',
        'full_name': 'Sinh Vien',
        'password': 'secret-pass-1',
      });
      expect(user.id, 'u9');
      expect(user.email, 's@university.edu');
      expect(user.name, 'Sinh Vien');
    });

    test('failure: no session token is rejected before any network call',
        () async {
      final client = UsersApiClient(
        tokenProvider: () async => null,
        client: MockClient((request) async =>
            fail('network must not be reached without a session')),
      );

      await expectLater(
        client.createAccount(
          role: UserRole.lecturer,
          email: 'l@university.edu',
          fullName: 'Giang Vien',
          password: 'secret-pass-1',
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('failure: backend rejection surfaces the detail message', () async {
      final client = UsersApiClient(
        tokenProvider: () async => 'token-123',
        client: MockClient((request) async =>
            _json({'detail': 'An account with this email already exists.'}, 409)),
      );

      await expectLater(
        client.createAccount(
          role: UserRole.student,
          email: 'dup@university.edu',
          fullName: 'Dup',
          password: 'secret-pass-1',
        ),
        throwsA(isA<ServerException>().having(
            (e) => e.message, 'message', 'An account with this email already exists.')),
      );
    });

    test('failure: unreachable server maps to NetworkException', () async {
      final client = UsersApiClient(
        tokenProvider: () async => 'token-123',
        client: MockClient((request) async => throw Exception('offline')),
      );

      await expectLater(
        client.createAccount(
          role: UserRole.student,
          email: 'a@b.co',
          fullName: 'A B',
          password: 'secret-pass-1',
        ),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
