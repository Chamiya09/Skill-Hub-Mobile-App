import '../models/candidate_interview.dart';
import 'api_service.dart';

class CandidateInterviewsService {
  CandidateInterviewsService({required this.token, ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final String token;
  final ApiService _apiService;

  Future<List<CandidateInterview>> getMyInterviews() async {
    try {
      final decoded = await _apiService.getJson(
        'Events/my-interviews',
        bearerToken: token,
      );
      if (decoded is! List) {
        throw const CandidateInterviewsException(
          'The server returned an unexpected interviews response.',
        );
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CandidateInterview.fromJson)
          .toList(growable: false);
    } on CandidateInterviewsException {
      rethrow;
    } on ApiException catch (error) {
      throw CandidateInterviewsException(error.message);
    }
  }

  void dispose() => _apiService.dispose();
}

class CandidateInterviewsException implements Exception {
  const CandidateInterviewsException(this.message);
  final String message;
}
