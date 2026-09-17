import 'package:dio/dio.dart';

import '../models/dashboard_stats.dart';
import 'auth_service.dart';

class DashboardData {
  const DashboardData({required this.companyName, required this.stats});
  final String companyName;
  final DashboardStats stats;
}

class DashboardService {
  DashboardService({Dio? dio, AuthService? authService})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {'Accept': 'application/json'},
            ),
          ),
      _authService = authService ?? AuthService();

  final Dio _dio;
  final AuthService _authService;

  Future<DashboardData> getOverview() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw const DashboardException(
        'Your session has expired. Please sign in again.',
      );
    }

    final options = Options(headers: {'Authorization': 'Bearer $token'});
    try {
      final statsResponse = await _dio.get<dynamic>(
        '/api/dashboard/stats',
        options: options,
      );
      final statsJson = _map(statsResponse.data);
      if (statsJson == null) {
        throw const DashboardException('The dashboard returned invalid data.');
      }

      var companyName = 'Enterprise Employer';
      try {
        final profileResponse = await _dio.get<dynamic>(
          '/api/company/me',
          options: options,
        );
        final profile = _map(profileResponse.data);
        companyName =
            _value(profile, 'companyName') ??
            _value(profile, 'fullName') ??
            companyName;
      } on DioException {
        // Dashboard data remains useful if the profile request is unavailable.
      }

      return DashboardData(
        companyName: companyName,
        stats: DashboardStats.fromJson(statsJson),
      );
    } on DashboardException {
      rethrow;
    } on DioException catch (error) {
      final message = _value(_map(error.response?.data), 'message');
      if (message != null) throw DashboardException(message);
      if (error.response?.statusCode == 401) {
        throw const DashboardException(
          'Your session has expired. Please sign in again.',
        );
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        throw const DashboardException(
          'Could not load the dashboard. Check the server connection.',
        );
      }
      throw const DashboardException('Unable to load company dashboard data.');
    }
  }

  Map<String, dynamic>? _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String? _value(Map<String, dynamic>? map, String key) {
    final value = map?[key]?.toString().trim();
    return value == null || value.isEmpty ? null : value;
  }
}

class DashboardException implements Exception {
  const DashboardException(this.message);
  final String message;
  @override
  String toString() => message;
}
