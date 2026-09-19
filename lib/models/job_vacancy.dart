class JobVacancy {
  const JobVacancy({
    required this.id,
    required this.title,
    required this.department,
    required this.location,
    required this.employmentType,
    required this.experienceLevel,
    required this.status,
    required this.description,
    required this.applicantsCount,
    this.companyName,
    this.salaryRange,
    this.whatWeOffer,
    this.createdAt,
  });
  final String id,
      title,
      department,
      location,
      employmentType,
      experienceLevel,
      status,
      description;
  final String? companyName, salaryRange, whatWeOffer;
  final int applicantsCount;
  final DateTime? createdAt;

  factory JobVacancy.fromJson(Map<String, dynamic> json) => JobVacancy(
    id: '${json['id'] ?? ''}',
    title: '${json['title'] ?? 'Untitled vacancy'}',
    department: '${json['department'] ?? 'General'}',
    location: '${json['location'] ?? 'Not specified'}',
    employmentType: '${json['employmentType'] ?? 'Full-time'}',
    experienceLevel: '${json['experienceLevel'] ?? 'Not specified'}',
    status: '${json['status'] ?? 'Active'}',
    description: '${json['description'] ?? ''}',
    companyName: json['companyName']?.toString(),
    salaryRange: json['salaryRange']?.toString(),
    whatWeOffer: json['whatWeOffer']?.toString(),
    applicantsCount: json['applicantsCount'] is num
        ? (json['applicantsCount'] as num).toInt()
        : 0,
    createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
  );
}

class JobInput {
  const JobInput({
    required this.title,
    required this.department,
    required this.location,
    required this.employmentType,
    required this.experienceLevel,
    required this.status,
    required this.description,
    this.salaryRange,
    this.whatWeOffer,
  });
  final String title,
      department,
      location,
      employmentType,
      experienceLevel,
      status,
      description;
  final String? salaryRange, whatWeOffer;

  Map<String, dynamic> toJson() => {
    'title': title,
    'department': department,
    'location': location,
    'employmentType': employmentType,
    'experienceLevel': experienceLevel,
    'salaryRange': salaryRange,
    'status': status,
    'description': description,
    'whatWeOffer': whatWeOffer,
  };
}
