import 'dart:convert';

import '../models/auth_session.dart';
import 'api_service.dart';
import 'auth_storage.dart';
import 'auth_storage_factory.dart';

class AuthService {
  AuthService({ApiService? apiService, AuthStorage? storage})
    : _apiService = apiService ?? ApiService(),
      _storage = storage ?? createAuthStorage();

  static const _tokenKey = 'skillhub_jwt_token';
  static const _tokenTypeKey = 'skillhub_token_type';
  static const _expiresKey = 'skillhub_token_expires_at';
  static const _userKey = 'skillhub_candidate_user';

  final ApiService _apiService;
  final AuthStorage _storage;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final decoded = await _apiService.postJson(
        'auth/candidate/login',
        body: {'email': email.trim(), 'password': password},
      );
      if (decoded is! Map<String, dynamic>) {
        throw const AuthException(
          'The server returned an invalid login response.',
        );
      }
      final session = AuthSession.fromJson(decoded);
      if (session.token.isEmpty || session.user.id.isEmpty) {
        throw const AuthException(
          'The server returned an incomplete login response.',
        );
      }
      if (session.user.role.toUpperCase() != 'CANDIDATE') {
        throw const AuthException('Please sign in with a candidate account.');
      }
      await _save(session);
      return session;
    } on AuthException {
      rethrow;
    } on ApiException catch (error) {
      throw AuthException(error.message);
    } on FormatException catch (error) {
      throw AuthException(error.message);
    }
  }

  Future<AuthSession?> restoreSession() async {
    try {
      final values = await Future.wait([
        _storage.read(_tokenKey),
        _storage.read(_tokenTypeKey),
        _storage.read(_expiresKey),
        _storage.read(_userKey),
      ]);
      final token = values[0];
      final rawUser = values[3];
      if (token == null || token.isEmpty || rawUser == null) return null;

      final userJson = jsonDecode(rawUser);
      if (userJson is! Map<String, dynamic>) return null;
      final session = AuthSession(
        token: token,
        tokenType: values[1] ?? 'Bearer',
        expiresAt: DateTime.tryParse(values[2] ?? ''),
        user: CandidateUser.fromJson(userJson),
      );
      if (session.isExpired || session.user.role.toUpperCase() != 'CANDIDATE') {
        await logout();
        return null;
      }
      return session;
    } catch (_) {
      try {
        await logout();
      } catch (_) {
        // Storage can be unavailable in privacy-restricted browser contexts.
      }
      return null;
    }
  }

  Future<void> logout() async {
    await Future.wait([
      _storage.delete(_tokenKey),
      _storage.delete(_tokenTypeKey),
      _storage.delete(_expiresKey),
      _storage.delete(_userKey),
    ]);
  }

  Future<void> _save(AuthSession session) async {
    await Future.wait([
      _storage.write(_tokenKey, session.token),
      _storage.write(_tokenTypeKey, session.tokenType),
      _storage.write(_expiresKey, session.expiresAt?.toIso8601String()),
      _storage.write(_userKey, jsonEncode(session.user.toJson())),
    ]);
  }

  void dispose() => _apiService.dispose();
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
}
