import '../models/saved_job.dart';
import 'api_service.dart';

class SavedJobsService {
  SavedJobsService({required this.token, ApiService? apiService})
    : _apiService = apiService ?? ApiService();
  final String token;
  final ApiService _apiService;
  Future<List<SavedJob>> getAll() async {
    try {
      final decoded = await _apiService.getJson(
        'candidate/saved-jobs',
        bearerToken: token,
      );
      if (decoded is! List) {
        throw const SavedJobsException(
          'The server returned an invalid saved-jobs response.',
        );
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(SavedJob.fromJson)
          .toList(growable: false);
    } on SavedJobsException {
      rethrow;
    } on ApiException catch (error) {
      throw SavedJobsException(error.message);
    }
  }

  Future<void> remove(String jobId) async {
    try {
      await _apiService.delete(
        'candidate/saved-jobs/$jobId',
        bearerToken: token,
      );
    } on ApiException catch (error) {
      throw SavedJobsException(error.message);
    }
  }

  void dispose() => _apiService.dispose();
}

class SavedJobsException implements Exception {
  const SavedJobsException(this.message);
  final String message;
}
