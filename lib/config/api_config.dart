import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  const ApiConfig._();

  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const _webBaseUrl = 'http://localhost:5155/api/';
  static const _androidEmulatorBaseUrl = 'http://10.0.2.2:5155/api/';

  /// Automatically selects the API host.
  /// Priority:
  /// 1. Loaded from .env (API_BASE_URL) via flutter_dotenv
  /// 2. Provided via compile-time --dart-define=API_BASE_URL=...
  /// 3. Local fallback (localhost / 10.0.2.2) when running locally
  static String get baseUrl {
    // 1. Check .env via flutter_dotenv
    if (dotenv.isInitialized) {
      final envUrl = dotenv.env['API_BASE_URL'];
      if (envUrl != null && envUrl.trim().isNotEmpty) {
        final clean = envUrl.trim();
        return clean.endsWith('/') ? clean : '$clean/';
      }
    }

    // 2. Check compile-time --dart-define=API_BASE_URL=...
    if (_configuredBaseUrl.isNotEmpty) {
      final clean = _configuredBaseUrl.trim();
      return clean.endsWith('/') ? clean : '$clean/';
    }

    // 3. Local fallback for development
    final fallback = kIsWeb ? _webBaseUrl : _androidEmulatorBaseUrl;
    return fallback.endsWith('/') ? fallback : '$fallback/';
  }

  static Uri endpoint(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final relativePath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse(baseUrl).resolve(relativePath).replace(
          queryParameters:
              queryParameters == null || queryParameters.isEmpty
                  ? null
                  : queryParameters,
        );
  }
}
