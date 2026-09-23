class CandidateApplication {
  const CandidateApplication({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.employmentType,
    required this.appliedDate,
    required this.status,
    this.department = '',
    this.companyLogoUrl,
  });

  factory CandidateApplication.fromJson(Map<String, dynamic> json) =>
      CandidateApplication(
        id: (json['applicationId'] ?? json['id'])?.toString() ?? '',
        jobId: json['jobId']?.toString() ?? '',
        jobTitle: json['jobTitle']?.toString() ?? 'Position',
        companyName: json['companyName']?.toString() ?? 'Skill Hub Partner',
        location: json['location']?.toString() ?? '',
        employmentType: json['employmentType']?.toString() ?? '',
        department: json['department']?.toString() ?? '',
        companyLogoUrl: json['companyLogoUrl']?.toString(),
        appliedDate: DateTime.tryParse(json['appliedDate']?.toString() ?? ''),
        status: json['status']?.toString() ?? 'Applied',
      );

  final String id,
      jobId,
      jobTitle,
      companyName,
      location,
      employmentType,
      department,
      status;
  final String? companyLogoUrl;
  final DateTime? appliedDate;

  String get companyInitials => companyName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0])
      .join()
      .toUpperCase();
}
