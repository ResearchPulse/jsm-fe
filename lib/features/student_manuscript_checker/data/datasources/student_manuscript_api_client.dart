import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/evaluation_history_response.dart';
import '../../domain/entities/evaluation_history_stats.dart';
import '../../domain/entities/journal_recommendation_response.dart';
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

  /// Streams real-time pipeline events from the backend Server-Sent Events (SSE) endpoint.
  Stream<Map<String, dynamic>> checkManuscriptStream({
    required List<int> fileBytes,
    required String filename,
    required String targetJournalId,
    bool includeExemplars = false,
  }) async* {
    final uri = Uri.parse(ApiEndpoints.studentManuscriptCheckStream);
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
      // Fallback: If streaming request fails to send, fallback to standard endpoint
      final fallbackResult = await checkManuscript(
        fileBytes: fileBytes,
        filename: filename,
        targetJournalId: targetJournalId,
        includeExemplars: includeExemplars,
      );
      yield {
        'event': 'analysis.completed',
        'stage': 'COMPLETED',
        'progress': 100,
        'message': 'Analysis complete',
        'data': fallbackResult.toMap(),
      };
      return;
    }

    if (streamedResponse.statusCode != 200) {
      final res = await http.Response.fromStream(streamedResponse);
      final errorMsg = _extractErrorMessage(res);
      yield {
        'event': 'analysis.failed',
        'status': 'FAILED',
        'message': errorMsg ?? 'Manuscript check failed (${res.statusCode}).',
        'progress': 0,
      };
      return;
    }

    final lineStream = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

    await for (final line in lineStream) {
      final trimmed = line.trim();
      if (trimmed.startsWith('data:')) {
        final payload = trimmed.substring(5).trim();
        if (payload.isNotEmpty) {
          try {
            final jsonMap = jsonDecode(payload) as Map<String, dynamic>;
            yield jsonMap;
          } catch (_) {
            // Ignore malformed ping or comment lines
          }
        }
      }
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
        Uri.parse(ApiEndpoints.studentAvailableJournals),
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

  /// Retrieves paginated manuscript evaluation history.
  Future<EvaluationHistoryResponse> getEvaluationHistory({
    int page = 1,
    int limit = 10,
    String sort = 'newest',
    String? journal,
    String? compatibility,
    String? search,
  }) async {
    final token = tokenProvider != null ? await tokenProvider!() : null;
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      'sort': sort,
      if (journal != null && journal.isNotEmpty) 'journal': journal,
      if (compatibility != null && compatibility.isNotEmpty) 'compatibility': compatibility,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri = Uri.parse(ApiEndpoints.studentEvaluations).replace(queryParameters: queryParams);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await _client.get(uri, headers: headers);
    if (response.statusCode != 200) {
      final msg = _extractErrorMessage(response);
      throw ServerException(msg ?? 'Failed to load evaluation history', response.statusCode);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>;
    return EvaluationHistoryResponse.fromMap(data);
  }

  /// Retrieves summary statistics of the user's evaluations.
  Future<EvaluationHistoryStats> getEvaluationStats() async {
    final token = tokenProvider != null ? await tokenProvider!() : null;
    final uri = Uri.parse(ApiEndpoints.studentEvaluationStats);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await _client.get(uri, headers: headers);
    if (response.statusCode != 200) {
      return const EvaluationHistoryStats();
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>;
    return EvaluationHistoryStats.fromMap(data);
  }

  /// Retrieves full evaluation snapshot detail.
  Future<ManuscriptCheckResult> getEvaluationDetail(String id) async {
    final token = tokenProvider != null ? await tokenProvider!() : null;
    final uri = Uri.parse('${ApiEndpoints.studentEvaluations}/$id');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await _client.get(uri, headers: headers);
    if (response.statusCode != 200) {
      final msg = _extractErrorMessage(response);
      throw ServerException(msg ?? 'Failed to load evaluation details', response.statusCode);
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>;
    final snapshot = data['result_snapshot'] as Map<String, dynamic>;
    return ManuscriptCheckResult.fromMap(snapshot);
  }

  /// Deletes an evaluation by ID.
  Future<void> deleteEvaluation(String id) async {
    final token = tokenProvider != null ? await tokenProvider!() : null;
    final uri = Uri.parse('${ApiEndpoints.studentEvaluations}/$id');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await _client.delete(uri, headers: headers);
    if (response.statusCode != 200) {
      final msg = _extractErrorMessage(response);
      throw ServerException(msg ?? 'Failed to delete evaluation', response.statusCode);
    }
  }

  /// Fetches closed-system journal recommendations for a manuscript or previous evaluation.
  Future<JournalRecommendationResponse> getJournalRecommendations({
    List<int>? fileBytes,
    String? filename,
    String? evaluationId,
  }) async {
    final uri = Uri.parse(ApiEndpoints.studentRecommendations);
    final request = http.MultipartRequest('POST', uri);

    final token = tokenProvider != null ? await tokenProvider!() : null;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (evaluationId != null && evaluationId.isNotEmpty) {
      request.fields['evaluation_id'] = evaluationId;
    }

    if (fileBytes != null && fileBytes.isNotEmpty) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: filename ?? 'manuscript.txt',
        ),
      );
    }

    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await _client.send(request);
    } catch (_) {
      throw const NetworkException('Could not reach the server.');
    }

    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>?;
      if (data != null) {
        return JournalRecommendationResponse.fromMap(data);
      }
      throw const ServerException('Empty recommendation response from server.', 200);
    }

    final errorMsg = _extractErrorMessage(response);
    throw ServerException(
      errorMsg ?? 'Failed to get journal recommendations (${response.statusCode})',
      response.statusCode,
    );
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
