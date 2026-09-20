class CandidateUser {
  const CandidateUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory CandidateUser.fromJson(Map<String, dynamic> json) {
    return CandidateUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString().trim().isNotEmpty == true
          ? json['fullName'].toString().trim()
          : [json['firstName'], json['lastName']]
                .whereType<String>()
                .where((part) => part.trim().isNotEmpty)
                .join(' '),
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'CANDIDATE',
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String role;

  String get firstName {
    final normalized = fullName.trim();
    return normalized.isEmpty
        ? 'Candidate'
        : normalized.split(RegExp(r'\s+')).first;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'role': role,
  };
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.tokenType,
    required this.expiresAt,
    required this.user,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    if (userJson is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid user data in authentication response.',
      );
    }
    return AuthSession(
      token: json['token']?.toString() ?? '',
      tokenType: json['tokenType']?.toString() ?? 'Bearer',
      expiresAt: DateTime.tryParse(json['expiresAt']?.toString() ?? ''),
      user: CandidateUser.fromJson(userJson),
    );
  }

  final String token;
  final String tokenType;
  final DateTime? expiresAt;
  final CandidateUser user;

  bool get isExpired =>
      expiresAt != null && DateTime.now().toUtc().isAfter(expiresAt!.toUtc());
}
