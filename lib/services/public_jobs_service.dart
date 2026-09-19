import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/job.dart';

class ApiConfig {
  const ApiConfig._();

  /// Uses localhost for Flutter Web and the Android emulator host alias on
  /// mobile. Override for a physical device or production:
  /// flutter run --dart-define=API_BASE_URL=https://api.example.com
  static String get baseUrl {
    const configured = String.fromEnvironment('API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured.endsWith('/')
          ? configured.substring(0, configured.length - 1)
          : configured;
    }

    return kIsWeb ? 'http://localhost:5155' : 'http://10.0.2.2:5155';
  }
}

class PublicJobsService {
  PublicJobsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Job>> getJobs({String? search, int? limit = 6}) async {
    final query = <String, String>{};
    final normalizedSearch = search?.trim() ?? '';
    if (normalizedSearch.isNotEmpty) query['search'] = normalizedSearch;
    if (limit != null && limit > 0) query['limit'] = '$limit';

    final baseUri = Uri.parse('${ApiConfig.baseUrl}/api/public/jobs');
    final uri = baseUri.replace(queryParameters: query.isEmpty ? null : query);

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw JobsApiException(_serverMessage(response));
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! List) {
        throw const JobsApiException(
          'The server returned an invalid jobs response.',
        );
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Job.fromJson)
          .where((job) => job.id.isNotEmpty)
          .toList(growable: false);
    } on JobsApiException {
      rethrow;
    } catch (_) {
      throw const JobsApiException(
        'Unable to connect to Skill Hub. Check that the backend is running.',
      );
    }
  }

  void dispose() => _client.close();

  String _serverMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body['message'] is String) {
        return body['message'] as String;
      }
    } catch (_) {
      // Use the status-based fallback below for non-JSON error responses.
    }
    return 'Unable to load jobs (HTTP ${response.statusCode}).';
  }
}

class JobsApiException implements Exception {
  const JobsApiException(this.message);
  final String message;
}
