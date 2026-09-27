import 'job.dart';

class CompanyProfile {
  const CompanyProfile({
    required this.id,
    required this.companyName,
    required this.contactEmail,
    this.phone,
    this.companySize,
    this.foundedYear,
    this.logoUrl,
    this.website,
    this.linkedinUrl,
    this.twitterUrl,
    this.githubUrl,
    this.location,
    this.industry,
    this.about,
    this.jobs = const [],
  });

  factory CompanyProfile.fromPayload(Map<String, dynamic> payload) {
    final rawCompany = payload['company'];
    final json = rawCompany is Map<String, dynamic> ? rawCompany : payload;
    final rawJobs = payload['jobs'];
    return CompanyProfile(
      id: json['id']?.toString() ?? '',
      companyName: _text(json['companyName'], fallback: 'Company'),
      contactEmail: _text(json['contactEmail']),
      phone: _optional(json['phone']),
      companySize: _optional(json['companySize']),
      foundedYear: _optional(json['foundedYear']),
      logoUrl: _optional(json['logoUrl']),
      website: _optional(json['website']),
      linkedinUrl: _optional(json['linkedinUrl']),
      twitterUrl: _optional(json['twitterUrl']),
      githubUrl: _optional(json['githubUrl']),
      location: _optional(json['location']),
      industry: _optional(json['industry']),
      about: _optional(json['about']),
      jobs: rawJobs is List
          ? rawJobs.whereType<Map<String, dynamic>>().map(Job.fromJson).toList()
          : const [],
    );
  }

  final String id;
  final String companyName;
  final String contactEmail;
  final String? phone;
  final String? companySize;
  final String? foundedYear;
  final String? logoUrl;
  final String? website;
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? githubUrl;
  final String? location;
  final String? industry;
  final String? about;
  final List<Job> jobs;

  String get initials => companyName
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .take(2)
      .map((word) => word[0])
      .join()
      .toUpperCase();
}

String _text(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String? _optional(Object? value) {
  final text = _text(value);
  return text.isEmpty ? null : text;
}
