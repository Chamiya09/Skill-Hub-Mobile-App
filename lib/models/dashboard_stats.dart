class DashboardStats {
  const DashboardStats({
    required this.activeVacanciesCount,
    required this.totalCandidatesCount,
    required this.candidatesThisWeekCount,
    required this.aiScreenedCount,
    required this.aiShortlistedCount,
    required this.shortlistedCount,
    required this.pendingInterviewsCount,
    required this.pendingAiEvaluationsCount,
    required this.topTalentMatches,
    required this.vacancyMetrics,
    this.recentAiActivity,
  });

  final int activeVacanciesCount;
  final int totalCandidatesCount;
  final int candidatesThisWeekCount;
  final int aiScreenedCount;
  final int aiShortlistedCount;
  final int shortlistedCount;
  final int pendingInterviewsCount;
  final int pendingAiEvaluationsCount;
  final List<TopTalentMatch> topTalentMatches;
  final List<VacancyMetric> vacancyMetrics;
  final RecentAiActivity? recentAiActivity;

  factory DashboardStats.fromJson(Map<String, dynamic> json) => DashboardStats(
    activeVacanciesCount: _integer(json['activeVacanciesCount']),
    totalCandidatesCount: _integer(json['totalCandidatesCount']),
    candidatesThisWeekCount: _integer(json['candidatesThisWeekCount']),
    aiScreenedCount: _integer(json['aiScreenedCount']),
    aiShortlistedCount: _integer(json['aiShortlistedCount']),
    shortlistedCount: _integer(json['shortlistedCount']),
    pendingInterviewsCount: _integer(json['pendingInterviewsCount']),
    pendingAiEvaluationsCount: _integer(json['pendingAiEvaluationsCount']),
    topTalentMatches: _list(json['topTalentMatches'])
        .map(TopTalentMatch.fromJson)
        .toList(growable: false),
    vacancyMetrics: _list(json['vacancyMetrics'])
        .map(VacancyMetric.fromJson)
        .toList(growable: false),
    recentAiActivity: json['recentAiActivity'] is Map
        ? RecentAiActivity.fromJson(
            Map<String, dynamic>.from(json['recentAiActivity'] as Map),
          )
        : null,
  );
}

class TopTalentMatch {
  const TopTalentMatch({
    required this.candidateName,
    required this.jobTitle,
    required this.matchPercentage,
    this.headline,
  });

  final String candidateName;
  final String? headline;
  final String jobTitle;
  final int matchPercentage;

  factory TopTalentMatch.fromJson(Map<String, dynamic> json) => TopTalentMatch(
    candidateName: _text(json['candidateName'], 'Candidate'),
    headline: json['headline']?.toString(),
    jobTitle: _text(json['jobTitle'], 'Vacancy'),
    matchPercentage: _integer(json['matchPercentage']),
  );
}

class VacancyMetric {
  const VacancyMetric({
    required this.title,
    required this.department,
    required this.status,
    required this.applicantsCount,
    required this.aiScreenedCount,
  });

  final String title;
  final String department;
  final String status;
  final int applicantsCount;
  final int aiScreenedCount;

  factory VacancyMetric.fromJson(Map<String, dynamic> json) => VacancyMetric(
    title: _text(json['title'], 'Vacancy'),
    department: _text(json['department'], 'General'),
    status: _text(json['status'], 'Active'),
    applicantsCount: _integer(json['applicantsCount']),
    aiScreenedCount: _integer(json['aiScreenedCount']),
  );
}

class RecentAiActivity {
  const RecentAiActivity({
    required this.jobTitle,
    required this.matchPercentage,
    required this.occurredAt,
  });

  final String jobTitle;
  final int matchPercentage;
  final DateTime? occurredAt;

  factory RecentAiActivity.fromJson(Map<String, dynamic> json) =>
      RecentAiActivity(
        jobTitle: _text(json['jobTitle'], 'Vacancy'),
        matchPercentage: _integer(json['matchPercentage']),
        occurredAt: DateTime.tryParse(json['occurredAt']?.toString() ?? ''),
      );
}

int _integer(dynamic value) => value is num ? value.toInt() : 0;
String _text(dynamic value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

List<Map<String, dynamic>> _list(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList(growable: false);
}
