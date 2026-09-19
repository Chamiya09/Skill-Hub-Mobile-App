class CompanyProfile {
  const CompanyProfile({
    required this.companyName,
    required this.adminName,
    required this.contactEmail,
    required this.phone,
    required this.companySize,
    required this.foundedYear,
    required this.logoUrl,
    required this.website,
    required this.linkedinUrl,
    required this.twitterUrl,
    required this.githubUrl,
    required this.location,
    required this.industry,
    required this.about,
  });

  final String companyName;
  final String adminName;
  final String contactEmail;
  final String phone;
  final String companySize;
  final String foundedYear;
  final String logoUrl;
  final String website;
  final String linkedinUrl;
  final String twitterUrl;
  final String githubUrl;
  final String location;
  final String industry;
  final String about;

  factory CompanyProfile.fromJson(Map<String, dynamic> json) => CompanyProfile(
    companyName: _text(json['companyName']),
    adminName: _text(json['adminName'] ?? json['fullName']),
    contactEmail: _text(json['contactEmail'] ?? json['email']),
    phone: _text(json['phone']),
    companySize: _text(json['companySize']),
    foundedYear: _text(json['foundedYear']),
    logoUrl: _text(json['logoUrl']),
    website: _text(json['website']),
    linkedinUrl: _text(json['linkedinUrl']),
    twitterUrl: _text(json['twitterUrl']),
    githubUrl: _text(json['githubUrl']),
    location: _text(json['location']),
    industry: _text(json['industry']),
    about: _text(json['about']),
  );

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'adminName': adminName,
    'contactEmail': contactEmail,
    'phone': phone,
    'companySize': companySize,
    'foundedYear': foundedYear,
    'logoUrl': logoUrl,
    'website': website,
    'linkedinUrl': linkedinUrl,
    'twitterUrl': twitterUrl,
    'githubUrl': githubUrl,
    'location': location,
    'industry': industry,
    'about': about,
  };
}

String _text(dynamic value) => value?.toString().trim() ?? '';
