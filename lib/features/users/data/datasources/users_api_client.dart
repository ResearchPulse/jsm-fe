import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_profile.dart';

/// HTTP client for the backend users module. Reuses the project's existing
/// http package; authenticated by the SSO session token from
/// [AuthRepository.currentToken]. The [Client] is injected for tests.
class UsersApiClient {
  final http.Client _client;
  final Future<String?> Function() tokenProvider;

  UsersApiClient({
    required this.tokenProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();
  Future<UserProfile> createAccount({
    required UserRole role,
    required String email,
    required String fullName,
    required String password,
  }) async {
    final token = await tokenProvider();
    if (token == null) {
      throw const ServerException(
          'You must be signed in to manage accounts.');
    }
    http.Response response;
    try {
      response = await _client.post(
        Uri.parse(ApiEndpoints.users),
        headers: {
          'Content-Type': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'role': role.value,
          'email': email,
          'full_name': fullName,
          'password': password,
        }),
      );
    } catch (e) {
      throw NetworkException('Could not reach the server.');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ServerException(
          _errorMessage(response) ?? 'Account creation failed.',
          response.statusCode);
    }
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return UserProfile(
        id: '${body['id'] ?? ''}',
        email: body['email'] as String? ?? email,
        name: body['full_name'] as String? ?? fullName,
      );
    } catch (_) {
      // 2xx with unparseable body: the account was created; surface it
      // with the submitted values rather than failing.
      return UserProfile(id: '', email: email, name: fullName);
    }
  }

  static String? _errorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = body['detail'];
      if (detail is String && detail.isNotEmpty) return detail;
      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map<String, dynamic>) {
          final msg = first['msg'];
          if (msg is String) return msg;
        }
      }
    } catch (_) {
      // Non-JSON error body.
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getUsers({String? role}) async {
    try {
      final token = await tokenProvider();
      final qs = role != null ? '?role=$role' : '';
      final uri = Uri.parse('${ApiEndpoints.users}$qs');
      final response = await _client.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final data = body['data'];
        if (data is List) {
          return data.whereType<Map<String, dynamic>>().toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> updateUser(
    String userId, {
    String? role,
    bool? isActive,
    String? fullName,
  }) async {
    final token = await tokenProvider();
    final uri = Uri.parse('${ApiEndpoints.users}/$userId');
    final payload = <String, dynamic>{};
    if (role != null) payload['role'] = role;
    if (isActive != null) payload['is_active'] = isActive;
    if (fullName != null) payload['full_name'] = fullName;

    final response = await _client.patch(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw ServerException(
        _errorMessage(response) ?? 'Cập nhật tài khoản thất bại.',
        response.statusCode,
      );
    }

    try {
      final body = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return (body['data'] as Map<String, dynamic>?) ?? {};
    } catch (_) {
      return {};
    }
  }

  Future<void> deleteUser(String userId) async {
    final token = await tokenProvider();
    final uri = Uri.parse('${ApiEndpoints.users}/$userId');
    final response = await _client.delete(
      uri,
      headers: {
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException(
        _errorMessage(response) ?? 'Xóa tài khoản thất bại.',
        response.statusCode,
      );
    }
  }
}

