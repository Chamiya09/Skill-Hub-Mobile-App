import '../models/candidate_assessment.dart';
import 'api_service.dart';

class CandidateAssessmentsService {
  CandidateAssessmentsService({required this.token, ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final String token;
  final ApiService _apiService;

  Future<List<CandidateAssessmentListItem>> getMyAssessments({String? candidateId}) async {
    try {
      dynamic decoded;
      try {
        decoded = await _apiService.getJson(
          'Assessments/candidate/my-assessments',
          bearerToken: token,
        );
      } catch (_) {
        if (candidateId != null && candidateId.isNotEmpty) {
          decoded = await _apiService.getJson(
            'Assessments/candidate/$candidateId',
            bearerToken: token,
          );
        } else {
          rethrow;
        }
      }

      if (decoded is! List) {
        throw const CandidateAssessmentsException(
          'The server returned an unexpected assessments response.',
        );
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CandidateAssessmentListItem.fromJson)
          .toList(growable: false);
    } on CandidateAssessmentsException {
      rethrow;
    } on ApiException catch (error) {
      throw CandidateAssessmentsException(error.message);
    } catch (_) {
      throw const CandidateAssessmentsException(
        'Failed to fetch technical assessments. Please try again.',
      );
    }
  }

  Future<AssessmentSubmissionDetail> getSubmissionDetail(String submissionId) async {
    try {
      final decoded = await _apiService.getJson(
        'Assessments/submissions/$submissionId',
        bearerToken: token,
      );
      if (decoded is! Map<String, dynamic>) {
        throw const CandidateAssessmentsException(
          'Failed to parse assessment submission details.',
        );
      }
      return AssessmentSubmissionDetail.fromJson(decoded);
    } on CandidateAssessmentsException {
      rethrow;
    } on ApiException catch (error) {
      throw CandidateAssessmentsException(error.message);
    } catch (_) {
      throw const CandidateAssessmentsException(
        'Failed to retrieve assessment scorecard details.',
      );
    }
  }

  void dispose() => _apiService.dispose();
}

class CandidateAssessmentsException implements Exception {
  const CandidateAssessmentsException(this.message);
  final String message;
}
