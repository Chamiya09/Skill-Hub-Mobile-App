import 'package:dio/dio.dart';

import '../models/pipeline_candidate.dart';
import 'auth_service.dart';

class AiPipelineService {
  AiPipelineService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 30),
          headers: const {'Accept': 'application/json'},
        ),
      );

  final Dio _dio;

  Future<Options> _options() async {
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      throw const AiPipelineException('Your session has expired.');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<PipelineCandidate>> getRankedApplicants(String jobId) =>
      _getCandidates('/api/jobs/$jobId/applicants');

  Future<List<PipelineCandidate>> getShortlisted(String jobId) =>
      _getCandidates('/api/jobs/$jobId/shortlisted');

  Future<List<PipelineCandidate>> runScreening(String jobId) async {
    try {
      final response = await _dio.post<dynamic>(
        '/api/jobs/$jobId/run-ai-screen',
        queryParameters: const {'forceRefresh': true},
        options: await _options(),
      );
      return _parseList(response.data);
    } on AiPipelineException {
      rethrow;
    } on DioException catch (error) {
      throw AiPipelineException(_message(error));
    }
  }

  Future<void> moveToShortlist(
    String jobId,
    Iterable<String> candidateIds,
  ) async {
    try {
      await _dio.post<dynamic>(
        '/api/jobs/$jobId/move-to-shortlist',
        data: candidateIds.toList(),
        options: await _options(),
      );
    } on AiPipelineException {
      rethrow;
    } on DioException catch (error) {
      throw AiPipelineException(_message(error));
    }
  }

  Future<List<PipelineCandidate>> _getCandidates(String path) async {
    try {
      final response = await _dio.get<dynamic>(path, options: await _options());
      return _parseList(response.data);
    } on AiPipelineException {
      rethrow;
    } on DioException catch (error) {
      throw AiPipelineException(_message(error));
    }
  }

  List<PipelineCandidate> _parseList(dynamic data) {
    if (data is! List) {
      throw const AiPipelineException('The pipeline returned invalid data.');
    }
    return data
        .whereType<Map>()
        .map(
          (item) => PipelineCandidate.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  String _message(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return 'Unable to load the AI hiring pipeline.';
  }
}

class AiPipelineException implements Exception {
  const AiPipelineException(this.message);
  final String message;
}
