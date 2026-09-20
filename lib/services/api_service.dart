import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<dynamic> getJson(
    String path, {
    Map<String, String>? queryParameters,
    String? bearerToken,
  }) async {
    final uri = ApiConfig.endpoint(path, queryParameters: queryParameters);

    try {
      final response = await _client
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
            },
          )
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

  Future<dynamic> postJson(
    String path, {
    required Map<String, dynamic> body,
    String? bearerToken,
  }) async {
    final uri = ApiConfig.endpoint(path);
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
    };

    try {
      final response = await _client
          .post(uri, headers: headers, body: jsonEncode(body))
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

  Future<void> delete(String path, {String? bearerToken}) async {
    final response = await _client
        .delete(
          ApiConfig.endpoint(path),
          headers: {
            'Accept': 'application/json',
            if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
          },
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(_serverMessage(response), response.statusCode);
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
