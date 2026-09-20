class Job {
  const Job({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.department,
    required this.location,
    required this.employmentType,
    required this.experienceLevel,
    required this.salaryRange,
    required this.createdAt,
    this.status = 'Active',
    this.description = '',
    this.whatWeOffer,
    this.tags = const [],
    this.logoUrl,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id']?.toString() ?? '',
      companyId: json['companyId']?.toString() ?? '',
      companyName: _string(json['companyName'], fallback: 'Enterprise Employer'),
      title: _string(json['title'], fallback: 'Untitled role'),
      department: _string(json['department']),
      location: _string(json['location'], fallback: 'Remote'),
      employmentType: _string(json['employmentType'], fallback: 'Full-time'),
      experienceLevel: _string(json['experienceLevel']),
      salaryRange: _nullableString(json['salaryRange']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      status: _string(json['status'], fallback: 'Active'),
      description: _string(json['description']),
      whatWeOffer: _nullableString(json['whatWeOffer']),
      tags: json['tags'] is List
          ? (json['tags'] as List)
              .map((tag) => tag.toString().trim())
              .where((tag) => tag.isNotEmpty)
              .toList(growable: false)
          : const [],
      logoUrl: _nullableString(json['logoUrl']),
    );
  }

  final String id;
  final String companyId;
  final String companyName;
  final String title;
  final String department;
  final String location;
  final String employmentType;
  final String experienceLevel;
  final String? salaryRange;
  final DateTime? createdAt;
  final String status;
  final String description;
  final String? whatWeOffer;
  final List<String> tags;
  final String? logoUrl;

  String get postedDateLabel {
    if (createdAt == null) return 'Recently posted';
    final date = createdAt!.toLocal();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String get companyInitials {
    final words = companyName.trim().split(RegExp(r'\s+'));
    return words
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0])
        .join()
        .toUpperCase();
  }

  String get salaryLabel {
    final salary = salaryRange?.trim();
    return salary == null || salary.isEmpty ? 'Competitive' : salary;
  }

  String get postedLabel {
    if (createdAt == null) return 'Recently posted';
    final difference = DateTime.now().difference(createdAt!.toLocal());
    if (difference.isNegative || difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    final date = createdAt!.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  List<String> get detailTags => [department, experienceLevel]
      .where((value) => value.trim().isNotEmpty)
      .toSet()
      .toList();

  static String _string(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static String? _nullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }
}
