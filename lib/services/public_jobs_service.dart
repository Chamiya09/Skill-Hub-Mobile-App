import '../models/job.dart';
import 'api_service.dart';

class PublicJobsService {
  PublicJobsService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<Job>> getJobs({String? search, int? limit = 6}) async {
    final query = <String, String>{};
    final normalizedSearch = search?.trim() ?? '';
    if (normalizedSearch.isNotEmpty) query['search'] = normalizedSearch;
    if (limit != null && limit > 0) query['limit'] = '$limit';

    try {
      final decoded = await _apiService.getJson(
        'public/jobs',
        queryParameters: query,
      );
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
    } on ApiException catch (error) {
      throw JobsApiException(error.message);
    }
  }

  Future<Job> getJobById(String id) async {
    try {
      final decoded = await _apiService.getJson('public/jobs/$id');
      if (decoded is! Map<String, dynamic>) {
        throw const JobsApiException(
          'The server returned an invalid job response.',
        );
      }
      return Job.fromJson(decoded);
    } on JobsApiException {
      rethrow;
    } on ApiException catch (error) {
      throw JobsApiException(error.message);
    }
  }

  void dispose() => _apiService.dispose();
}

class JobsApiException implements Exception {
  const JobsApiException(this.message);
  final String message;
}
