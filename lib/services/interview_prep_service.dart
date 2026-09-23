import 'package:flutter/foundation.dart';

import 'api_service.dart';

class InterviewPrepService {
  InterviewPrepService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<InterviewPrepGuide>> getMyGuides(String token) async {
    final payload = await _apiService.getJson(
      '/interviewprep/my-guides',
      bearerToken: token,
    );
    if (payload is! List) {
      throw const FormatException(
        'Invalid interview preparation guides response.',
      );
    }
    return payload
        .whereType<Map<String, dynamic>>()
        .map(InterviewPrepGuide.fromJson)
        .toList();
  }

  void dispose() => _apiService.dispose();
}

@immutable
class InterviewPrepGuide {
  const InterviewPrepGuide({
    required this.jobTitle,
    required this.targetRole,
    this.companyName,
    this.roleOverviewSummary,
    this.theoreticalAreas = const [],
    this.practicalAreas = const [],
    this.proTips = const [],
    this.preparationChecklist = const [],
  });

  factory InterviewPrepGuide.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list(String key) {
      final value = json[key];
      if (value is! List) return const [];
      return value.whereType<Map<String, dynamic>>().toList();
    }

    List<String> strings(String key) {
      final value = json[key];
      if (value is! List) return const [];
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return InterviewPrepGuide(
      jobTitle: _text(json['jobTitle'], fallback: 'Selected Role'),
      targetRole: _text(json['targetRole']),
      companyName: _optionalText(json['companyName']),
      roleOverviewSummary: _optionalText(json['roleOverviewSummary']),
      theoreticalAreas: list('keyTheoreticalAreas')
          .map(StudyFocusArea.fromJson)
          .toList(),
      practicalAreas: list('practicalImplementationFocus')
          .map(StudyFocusArea.fromJson)
          .toList(),
      proTips: strings('proTips'),
      preparationChecklist: strings('preparationChecklist'),
    );
  }

  final String jobTitle;
  final String targetRole;
  final String? companyName;
  final String? roleOverviewSummary;
  final List<StudyFocusArea> theoreticalAreas;
  final List<StudyFocusArea> practicalAreas;
  final List<String> proTips;
  final List<String> preparationChecklist;

  String get displayRole => targetRole.isNotEmpty ? targetRole : jobTitle;
}

@immutable
class StudyFocusArea {
  const StudyFocusArea({
    required this.title,
    this.priority,
    this.estimatedStudyTime,
    this.overview,
    this.conceptsToReview = const [],
    this.practicalApplication,
    this.coachTip,
  });

  factory StudyFocusArea.fromJson(Map<String, dynamic> json) {
    final concepts = json['conceptsToReview'];
    return StudyFocusArea(
      title: _text(json['title'], fallback: 'Focus area'),
      priority: _optionalText(json['priority']),
      estimatedStudyTime: _optionalText(json['estimatedStudyTime']),
      overview: _optionalText(json['overview']),
      conceptsToReview: concepts is List
          ? concepts
                .map((item) => item.toString().trim())
                .where((item) => item.isNotEmpty)
                .toList()
          : const [],
      practicalApplication: _optionalText(json['practicalApplication']),
      coachTip: _optionalText(json['coachTip']),
    );
  }

  final String title;
  final String? priority;
  final String? estimatedStudyTime;
  final String? overview;
  final List<String> conceptsToReview;
  final String? practicalApplication;
  final String? coachTip;
}

String _text(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

String? _optionalText(Object? value) {
  final text = _text(value);
  return text.isEmpty ? null : text;
}
