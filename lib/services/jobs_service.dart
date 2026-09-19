import 'package:dio/dio.dart';

import '../models/job_vacancy.dart';
import 'auth_service.dart';

class JobsService {
  JobsService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
  final Dio _dio;

  Future<Options> _options() async {
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw const JobsException('Your session has expired.');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<JobVacancy>> getJobs() async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/jobs',
        options: await _options(),
      );
      final list = response.data;
      if (list is! List) throw const JobsException('Invalid jobs response.');
      return list
          .whereType<Map>()
          .map((item) => JobVacancy.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on JobsException {
      rethrow;
    } on DioException catch (error) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        throw JobsException(data['message']);
      }
      throw const JobsException('Unable to load job vacancies.');
    }
  }

  Future<JobVacancy> createJob(JobInput input) => _save(null, input);
  Future<JobVacancy> updateJob(String id, JobInput input) => _save(id, input);

  Future<JobVacancy> _save(String? id, JobInput input) async {
    try {
      final response = id == null
          ? await _dio.post<dynamic>(
              '/api/jobs',
              data: input.toJson(),
              options: await _options(),
            )
          : await _dio.put<dynamic>(
              '/api/jobs/$id',
              data: input.toJson(),
              options: await _options(),
            );
      if (response.data is! Map) {
        throw const JobsException('Invalid job response.');
      }
      return JobVacancy.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    } on JobsException {
      rethrow;
    } on DioException catch (error) {
      throw JobsException(_message(error));
    }
  }

  Future<void> deleteJob(String id) async {
    try {
      await _dio.delete<void>('/api/jobs/$id', options: await _options());
    } on JobsException {
      rethrow;
    } on DioException catch (error) {
      throw JobsException(_message(error));
    }
  }

  String _message(DioException error) {
    final data = error.response?.data;
    if (data is Map) {
      final message = data['message'] ?? data['title'];
      if (message is String && message.isNotEmpty) return message;
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
      }
    }
    return 'Unable to save the job vacancy.';
  }
}

class JobsException implements Exception {
  const JobsException(this.message);
  final String message;
}
