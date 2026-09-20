import '../models/candidate_application.dart';
import 'api_service.dart';

class CandidateApplicationsService {
  CandidateApplicationsService({required this.token, ApiService? apiService})
    : _apiService = apiService ?? ApiService();
  final String token;
  final ApiService _apiService;

  Future<List<CandidateApplication>> getMyApplications() async {
    try {
      final decoded = await _apiService.getJson(
        'candidate/applications',
        bearerToken: token,
      );
      if (decoded is! List) {
        throw const CandidateApplicationsException(
          'The server returned an invalid applications response.',
        );
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CandidateApplication.fromJson)
          .toList(growable: false);
    } on CandidateApplicationsException {
      rethrow;
    } on ApiException catch (error) {
      throw CandidateApplicationsException(error.message);
    }
  }

  void dispose() => _apiService.dispose();
}

class CandidateApplicationsException implements Exception {
  const CandidateApplicationsException(this.message);
  final String message;
}
