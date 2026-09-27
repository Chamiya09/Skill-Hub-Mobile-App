import '../models/company_profile.dart';
import 'api_service.dart';

class CompanyProfileService {
  CompanyProfileService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<CompanyProfile> getProfile(String identifier) async {
    final payload = await _apiService.getJson(
      'companies/${Uri.encodeComponent(identifier)}',
    );
    if (payload is! Map<String, dynamic>) {
      throw const CompanyProfileException('Invalid company profile response.');
    }
    return CompanyProfile.fromPayload(payload);
  }

  void dispose() => _apiService.dispose();
}

class CompanyProfileException implements Exception {
  const CompanyProfileException(this.message);
  final String message;
}
