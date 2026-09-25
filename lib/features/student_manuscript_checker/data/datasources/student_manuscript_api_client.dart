import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/manuscript_check_result.dart';
import '../../domain/entities/target_journal.dart';

/// HTTP client for backend Student Manuscript Checker endpoints.
///
/// Follows project convention using the standard [http.Client], supporting
/// session token injection from AuthRepository when available.
class StudentManuscriptApiClient {
  final http.Client _client;
  final Future<String?> Function()? tokenProvider;

  StudentManuscriptApiClient({
    this.tokenProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Submits a manuscript file to be checked against a target journal style profile.
  Future<ManuscriptCheckResult> checkManuscript({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) async {
    final uri = Uri.parse(ApiEndpoints.studentManuscriptCheck);
    final request = http.MultipartRequest('POST', uri);

    if (tokenProvider != null) {
      final token = await tokenProvider!();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    request.fields['target_journal_id'] = targetJournalId;
    request.fields['include_exemplars'] = includeExemplars.toString();

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: filename,
      ),
    );

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await _client.send(request);
    } catch (e) {
      throw const NetworkException('Could not reach the server.');
    }

    http.Response response;
    try {
      response = await http.Response.fromStream(streamedResponse);
    } catch (e) {
      throw const NetworkException('Error reading response stream.');
    }

    if (response.statusCode != 200) {
      final errorMsg = _extractErrorMessage(response);
      throw ServerException(
        errorMsg ?? 'Manuscript check failed.',
        response.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;
      return ManuscriptCheckResult.fromMap(data);
    } catch (e) {
      throw ServerException(
        'Invalid server response format: ${e.toString()}',
        response.statusCode,
      );
    }
  }

  /// Fetches available journals that can be used for benchmarking.
  Future<List<TargetJournal>> getAvailableJournals() async {
    final token = tokenProvider != null ? await tokenProvider!() : null;
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await _client.get(
        Uri.parse(ApiEndpoints.adminJournals),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final data = decoded['data'];
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(TargetJournal.fromMap)
              .toList();
        }
      }
    } catch (_) {
      // Fallback: endpoint might not be available or network error.
    }

    return const [];
  }

  static String? _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        if (body['error'] is Map<String, dynamic>) {
          final err = body['error'] as Map<String, dynamic>;
          if (err['message'] is String && (err['message'] as String).isNotEmpty) {
            return err['message'] as String;
          }
        }
        final detail = body['detail'];
        if (detail is String && detail.isNotEmpty) return detail;
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map<String, dynamic>) {
            final msg = first['msg'];
            if (msg is String && msg.isNotEmpty) return msg;
          }
        }
        if (body['message'] is String && (body['message'] as String).isNotEmpty) {
          return body['message'] as String;
        }
      }
    } catch (_) {
      // Non-JSON error body
    }
    return null;
  }
}
