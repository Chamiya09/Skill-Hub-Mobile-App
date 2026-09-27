import 'package:flutter/foundation.dart';

import 'api_service.dart';

class CandidateCvService {
  CandidateCvService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<CandidateCvProfile> getProfile(String token) async {
    final payload = await _apiService.getJson(
      '/candidate/profile',
      bearerToken: token,
    );
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Invalid Digital CV response.');
    }
    return CandidateCvProfile.fromJson(payload);
  }

  void dispose() => _apiService.dispose();
}

@immutable
class CandidateCvProfile {
  const CandidateCvProfile({
    required this.fullName,
    required this.email,
    this.headline,
    this.phone,
    this.location,
    this.experience,
    this.availability,
    this.avatarUrl,
    this.website,
    this.linkedinUrl,
    this.githubUrl,
    this.summary,
    this.highlights = const [],
    this.experiences = const [],
    this.educations = const [],
    this.projects = const [],
    this.skills = const [],
    this.certifications = const [],
  });

  factory CandidateCvProfile.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String key) {
      final value = json[key];
      if (value is! List) return const [];
      return value.whereType<Map<String, dynamic>>().toList();
    }

    return CandidateCvProfile(
      fullName: _text(json['fullName'], fallback: 'Candidate'),
      email: _text(json['email']),
      headline: _optionalText(json['headline']),
      phone: _optionalText(json['phone']),
      location: _optionalText(json['location']),
      experience: _optionalText(json['experience']),
      availability: _optionalText(json['availability']),
      avatarUrl: _optionalText(json['avatarUrl']),
      website: _optionalText(json['website']),
      linkedinUrl: _optionalText(json['linkedinUrl']),
      githubUrl: _optionalText(json['githubUrl']),
      summary: _optionalText(json['summary']),
      highlights: list('keyHighlights')
          .map(CandidateCvHighlight.fromJson)
          .toList(),
      experiences: list('experiences')
          .map(CandidateCvExperience.fromJson)
          .toList(),
      educations: list('educations')
          .map(CandidateCvEducation.fromJson)
          .toList(),
      projects: list('projects').map(CandidateCvProject.fromJson).toList(),
      skills: list('skills').map(CandidateCvSkill.fromJson).toList(),
      certifications: list('certifications')
          .map(CandidateCvCertification.fromJson)
          .toList(),
    );
  }

  final String fullName;
  final String email;
  final String? headline;
  final String? phone;
  final String? location;
  final String? experience;
  final String? availability;
  final String? avatarUrl;
  final String? website;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? summary;
  final List<CandidateCvHighlight> highlights;
  final List<CandidateCvExperience> experiences;
  final List<CandidateCvEducation> educations;
  final List<CandidateCvProject> projects;
  final List<CandidateCvSkill> skills;
  final List<CandidateCvCertification> certifications;
}

@immutable
class CandidateCvHighlight {
  const CandidateCvHighlight(this.category, this.value, this.subtext);

  factory CandidateCvHighlight.fromJson(Map<String, dynamic> json) =>
      CandidateCvHighlight(
        _text(json['category']),
        _text(json['value']),
        _optionalText(json['subtext']),
      );

  final String category;
  final String value;
  final String? subtext;
}

@immutable
class CandidateCvExperience {
  const CandidateCvExperience({
    required this.jobTitle,
    required this.company,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.description,
    this.location,
  });

  factory CandidateCvExperience.fromJson(Map<String, dynamic> json) =>
      CandidateCvExperience(
        jobTitle: _text(
          json['title'] ?? json['jobTitle'],
          fallback: 'Experience',
        ),
        company: _text(json['company'] ?? json['companyName']),
        startDate: _optionalText(json['startDate']),
        endDate: _optionalText(json['endDate']),
        isCurrent: json['isCurrent'] == true,
        description: _optionalText(json['description']),
        location: _optionalText(json['location']),
      );

  final String jobTitle;
  final String company;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;
  final String? location;
}

@immutable
class CandidateCvEducation {
  const CandidateCvEducation({
    required this.degree,
    required this.institution,
    this.year,
  });

  factory CandidateCvEducation.fromJson(Map<String, dynamic> json) =>
      CandidateCvEducation(
        degree: _text(json['degree'], fallback: 'Education'),
        institution: _text(json['institution'] ?? json['school']),
        year: _optionalText(
          json['endYear'] ?? json['startYear'] ?? json['year'],
        ),
      );

  final String degree;
  final String institution;
  final String? year;
}

@immutable
class CandidateCvProject {
  const CandidateCvProject({
    required this.name,
    this.role,
    this.description,
    this.link,
  });

  factory CandidateCvProject.fromJson(Map<String, dynamic> json) =>
      CandidateCvProject(
        name: _text(json['projectName'] ?? json['name'], fallback: 'Project'),
        role: _optionalText(json['role']),
        description: _optionalText(json['description']),
        link: _optionalText(json['link'] ?? json['liveUrl']),
      );

  final String name;
  final String? role;
  final String? description;
  final String? link;
}

@immutable
class CandidateCvSkill {
  const CandidateCvSkill(this.name, this.category);

  factory CandidateCvSkill.fromJson(Map<String, dynamic> json) =>
      CandidateCvSkill(
        _text(json['skillName'] ?? json['name']),
        _optionalText(json['category']),
      );

  final String name;
  final String? category;
}

@immutable
class CandidateCvCertification {
  const CandidateCvCertification({
    required this.title,
    required this.organization,
    this.date,
    this.url,
  });

  factory CandidateCvCertification.fromJson(Map<String, dynamic> json) =>
      CandidateCvCertification(
        title: _text(json['title'], fallback: 'Certification'),
        organization: _text(
          json['issuingOrganization'] ?? json['organization'],
        ),
        date: _optionalText(json['issueDate']),
        url: _optionalText(json['credentialUrl']),
      );

  final String title;
  final String organization;
  final String? date;
  final String? url;
}

String _text(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String? _optionalText(Object? value) {
  final text = _text(value);
  return text.isEmpty ? null : text;
}
