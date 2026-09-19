import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<dynamic> getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = ApiConfig.endpoint(path, queryParameters: queryParameters);

    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw ApiException(_serverMessage(response), response.statusCode);
      }

      return jsonDecode(response.body);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
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
      // Use the HTTP status fallback for non-JSON error responses.
    }
    return 'Request failed (HTTP ${response.statusCode}).';
  }
}

class ApiException implements Exception {
  const ApiException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;
}
