import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jsm_fe/core/errors/exceptions.dart';
import 'package:jsm_fe/features/student_manuscript_checker/data/datasources/student_manuscript_api_client.dart';

void main() {
  group('StudentManuscriptApiClient', () {
    final sampleResultData = {
      'suitability_score': 88.5,
      'rating_level': 'EXCELLENT_ALIGNMENT',
      'summary':
          'The manuscript shows excellent alignment with the target journal.',
      'section_scores': {
        'INTRO': 92.0,
        'METHODS': 85.0,
      },
      'feature_comparison': {
        'sentence_length': {
          'user_median': 18.5,
          'journal_median': 20.0,
          'journal_p10': 12.0,
          'journal_p90': 28.0,
          'status': 'WITHIN_RANGE',
        },
        'voice_and_person': {
          'user_passive_rate': 0.25,
          'journal_passive_rate': 0.22,
          'user_we_rate': 0.05,
          'journal_we_rate': 0.08,
        },
        'additional': {
          'stance': {
            'user_hedge_rate_per_1k': 12.0,
            'journal_hedge_rate_per_1k': 15.0,
            'user_booster_rate_per_1k': 8.0,
            'journal_booster_rate_per_1k': 9.0,
          },
        },
      },
      'warnings': [
        {
          'id': 'W-GAP-01',
          'severity': 'CRITICAL',
          'section': 'INTRO',
          'title': 'Missing Research Gap',
          'message': 'The manuscript section does not contain a research gap.',
          'exemplar': {
            'text': 'However, prior approaches remain limited.',
            'article_title': 'A Real Journal Article',
            'doi': '10.1234/example',
          },
        },
      ],
    };

    test('success: posts multipart file with target_journal_id and bearer token',
        () async {
      Uri? capturedUri;
      String? capturedAuth;
      final capturedFields = <String, String>{};
      final capturedFiles = <String>[];

      final mockClient = MockClient.streaming((request, bodyStream) async {
        capturedUri = request.url;
        capturedAuth = request.headers['Authorization'];
        if (request is http.MultipartRequest) {
          capturedFields.addAll(request.fields);
          capturedFiles.addAll(request.files.map((f) => f.field));
        }
        final bytes = utf8.encode(jsonEncode({
          'success': true,
          'data': sampleResultData,
          'message': 'Manuscript suitability check completed.',
        }));
        return http.StreamedResponse(
          Stream.value(bytes),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = StudentManuscriptApiClient(
        tokenProvider: () async => 'sso-token-xyz',
        client: mockClient,
      );

      final result = await client.checkManuscript(
        fileBytes: utf8.encode('Introduction\nDraft manuscript content.'),
        filename: 'test_draft.txt',
        targetJournalId: 'j-uuid-1234',
        includeExemplars: true,
      );

      expect(
          capturedUri!.toString(), contains('/api/v1/student/manuscript/check'));
      expect(capturedAuth, 'Bearer sso-token-xyz');
      expect(capturedFields['target_journal_id'], 'j-uuid-1234');
      expect(capturedFields['include_exemplars'], 'true');
      expect(capturedFiles, contains('file'));

      expect(result.suitabilityScore, 88.5);
      expect(result.ratingLevel, 'EXCELLENT_ALIGNMENT');
      expect(result.ratingLabel, 'Excellent Alignment');
      expect(result.isExcellent, isTrue);
      expect(result.summary, contains('excellent alignment'));
      expect(result.sectionScores['INTRO'], 92.0);
      expect(result.featureComparison.sentenceLength?.userMedian, 18.5);
      expect(result.featureComparison.voiceAndPerson?.userPassiveRate, 0.25);
      expect(result.featureComparison.stance?.userHedgeRate, 12.0);
      expect(result.warnings.length, 1);
      expect(result.hasMissingGap, isTrue);
      expect(result.validatedExemplars.length, 1);
      expect(result.validatedExemplars.first.doi, '10.1234/example');
    });

    test('failure: backend 404 surfaces error message as ServerException',
        () async {
      final mockClient = MockClient.streaming((request, bodyStream) async {
        final bytes = utf8.encode(jsonEncode({
          'success': false,
          'error': {
            'code': 'NOT_FOUND',
            'message': 'Journal with ID j-999 not found',
          },
        }));
        return http.StreamedResponse(
          Stream.value(bytes),
          404,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = StudentManuscriptApiClient(client: mockClient);

      await expectLater(
        client.checkManuscript(
          fileBytes: [1, 2, 3],
          filename: 'draft.txt',
          targetJournalId: 'j-999',
        ),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'Journal with ID j-999 not found',
          ),
        ),
      );
    });

    test('failure: network error throws NetworkException', () async {
      final mockClient = MockClient.streaming((request, bodyStream) async {
        throw Exception('Connection refused');
      });

      final client = StudentManuscriptApiClient(client: mockClient);

      await expectLater(
        client.checkManuscript(
          fileBytes: [1, 2, 3],
          filename: 'draft.txt',
          targetJournalId: 'j-1',
        ),
        throwsA(isA<NetworkException>()),
      );
    });

    test('getAvailableJournals returns parsed list on 200 OK', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': [
              {
                'id': 'j1',
                'title': 'IEEE TSE',
                'domain': 'Software Engineering',
              },
              {
                'id': 'j2',
                'title': 'ACM TOSEM',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final client = StudentManuscriptApiClient(client: mockClient);
      final journals = await client.getAvailableJournals();

      expect(journals.length, 2);
      expect(journals[0].id, 'j1');
      expect(journals[0].title, 'IEEE TSE');
      expect(journals[0].domain, 'Software Engineering');
      expect(journals[1].id, 'j2');
    });
  });
}
