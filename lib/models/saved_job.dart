class SavedJob {
  const SavedJob({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.location,
    required this.employmentType,
    required this.experienceLevel,
    required this.savedAt,
    required this.postedAt,
    this.companyLogoUrl,
    this.salaryRange,
  });
  factory SavedJob.fromJson(Map<String, dynamic> json) => SavedJob(
    id: json['id']?.toString() ?? '',
    jobId: json['jobId']?.toString() ?? '',
    jobTitle: json['jobTitle']?.toString() ?? 'Position',
    companyName: json['companyName']?.toString() ?? 'Skill Hub Partner',
    companyLogoUrl: json['companyLogoUrl']?.toString(),
    location: json['location']?.toString() ?? '',
    employmentType: json['employmentType']?.toString() ?? '',
    experienceLevel: json['experienceLevel']?.toString() ?? '',
    salaryRange: json['salaryRange']?.toString(),
    postedAt: DateTime.tryParse(json['postedAt']?.toString() ?? ''),
    savedAt: DateTime.tryParse(json['savedAt']?.toString() ?? ''),
  );
  final String id,
      jobId,
      jobTitle,
      companyName,
      location,
      employmentType,
      experienceLevel;
  final String? companyLogoUrl, salaryRange;
  final DateTime? postedAt, savedAt;
  String get companyInitials => companyName
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0])
      .join()
      .toUpperCase();
}
