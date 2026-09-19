class PipelineCandidate {
  const PipelineCandidate({
    required this.applicationId,
    required this.candidateId,
    required this.name,
    required this.email,
    required this.headline,
    required this.location,
    required this.status,
    required this.skills,
    this.aiScore,
    this.appliedAt,
  });

  final String applicationId;
  final String candidateId;
  final String name;
  final String email;
  final String headline;
  final String location;
  final String status;
  final List<String> skills;
  final int? aiScore;
  final DateTime? appliedAt;

  factory PipelineCandidate.fromJson(Map<String, dynamic> json) {
    final rawSkills = json['skills'];
    return PipelineCandidate(
      applicationId: '${json['applicationId'] ?? ''}',
      candidateId: '${json['candidateId'] ?? ''}',
      name: '${json['fullName'] ?? 'Candidate'}',
      email: '${json['email'] ?? ''}',
      headline: '${json['headline'] ?? 'Candidate Profile'}',
      location: '${json['location'] ?? 'Location unspecified'}',
      status: '${json['status'] ?? 'Shortlisted'}',
      skills: rawSkills is List
          ? rawSkills.map((skill) => skill.toString()).toList()
          : const [],
      aiScore: json['aiMatchScore'] is num
          ? (json['aiMatchScore'] as num).round()
          : null,
      appliedAt: DateTime.tryParse(
        '${json['shortlistedAt'] ?? json['appliedDate'] ?? ''}',
      ),
    );
  }
}
