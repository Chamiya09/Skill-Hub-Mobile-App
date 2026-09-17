import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfig {
  ApiConfig._();
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // 10.0.2.2 maps the Android emulator to the development machine.
    // The .NET backend's HTTP launch profile listens on port 5155.
    defaultValue: 'http://10.0.2.2:5155',
  );
}

class AuthService {
  AuthService({Dio? dio, FlutterSecureStorage? storage})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              responseType: ResponseType.json,
              receiveDataWhenStatusError: true,
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          ),
      _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_jwt';
  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<void> login({required String email, required String password}) async {
    try {
      final response = await _dio.post<dynamic>(
        '/api/company/login',
        data: {'email': email.trim(), 'password': password},
      );

      final body = _asJsonMap(response.data);
      final token = body?['token'] ?? body?['Token'];
      if (token is! String || token.isEmpty) {
        throw const AuthException(
          'The server did not return an authentication token.',
        );
      }
      await _storage.write(key: _tokenKey, value: token);
    } on DioException catch (error) {
      throw AuthException(_errorMessage(error));
    } on PlatformException catch (_) {
      throw const AuthException(
        'Login succeeded, but the secure session could not be saved. '
        'Please restart the app and try again.',
      );
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Unable to complete login. Please try again.');
    }
  }

  Map<String, dynamic>? _asJsonMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<String?> getToken() => _storage.read(key: _tokenKey);
  Future<void> logout() => _storage.delete(key: _tokenKey);

  Future<bool> hasValidToken() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return false;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;
      final expiry = payload['exp'];
      return expiry is num &&
          DateTime.fromMillisecondsSinceEpoch(
            expiry.toInt() * 1000,
            isUtc: true,
          ).isAfter(DateTime.now().toUtc());
    } catch (_) {
      return false;
    }
  }

  String _errorMessage(DioException error) {
    final data = _asJsonMap(error.response?.data);
    if (data != null) {
      final message = data['message'] ?? data['title'];
      if (message is String && message.trim().isNotEmpty) return message;
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    final statusCode = error.response?.statusCode;
    if (statusCode == 400) return 'Please check your email and password.';
    if (statusCode == 401) return 'Invalid company email or password.';
    if (statusCode == 404) {
      return 'The company login service was not found.';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'The server could not complete the login. Please try again.';
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Could not connect to the server. Please try again.';
    }
    return 'Unable to sign in. Please try again.';
  }
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}
