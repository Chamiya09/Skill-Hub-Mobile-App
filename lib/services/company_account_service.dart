import 'package:dio/dio.dart';

import '../models/company_profile.dart';
import 'auth_service.dart';

class CompanyAccountService {
  CompanyAccountService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: const {'Accept': 'application/json'},
        ),
      );

  final Dio _dio;

  Future<Options> _options() async {
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw const CompanyAccountException('Your session has expired.');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<CompanyProfile> getProfile() async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/company/me',
        options: await _options(),
      );
      return CompanyProfile.fromJson(_map(response.data));
    } on CompanyAccountException {
      rethrow;
    } on DioException catch (error) {
      throw CompanyAccountException(_message(error));
    }
  }

  Future<CompanyProfile> updateProfile(CompanyProfile profile) async {
    try {
      final response = await _dio.put<dynamic>(
        '/api/company/profile',
        data: profile.toJson(),
        options: await _options(),
      );
      return CompanyProfile.fromJson(_map(response.data));
    } on CompanyAccountException {
      rethrow;
    } on DioException catch (error) {
      throw CompanyAccountException(_message(error));
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await _dio.put<dynamic>(
        '/api/company/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmNewPassword': confirmNewPassword,
        },
        options: await _options(),
      );
    } on CompanyAccountException {
      rethrow;
    } on DioException catch (error) {
      throw CompanyAccountException(_message(error));
    }
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const CompanyAccountException('The account returned invalid data.');
  }

  String _message(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['title'];
      if (message is String && message.trim().isNotEmpty) return message;
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    return 'Unable to update the company account.';
  }
}

class CompanyAccountException implements Exception {
  const CompanyAccountException(this.message);
  final String message;
}
