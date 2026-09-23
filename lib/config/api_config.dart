import 'package:flutter/foundation.dart';

class ApiConfig {
  const ApiConfig._();

  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static const _webBaseUrl = 'http://localhost:5155/api/';
  static const _androidEmulatorBaseUrl = 'http://10.0.2.2:5155/api/';

  /// Automatically selects the host that can reach the local .NET backend.
  /// API_BASE_URL always wins when supplied for a physical device or release.
  static String get baseUrl {
    final selected = _configuredBaseUrl.isNotEmpty
        ? _configuredBaseUrl
        : (kIsWeb ? _webBaseUrl : _androidEmulatorBaseUrl);
    return selected.endsWith('/') ? selected : '$selected/';
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
