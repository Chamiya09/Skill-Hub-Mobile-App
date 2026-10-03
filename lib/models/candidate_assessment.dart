class CandidateAssessmentListItem {
  const CandidateAssessmentListItem({
    required this.submissionId,
    required this.assessmentId,
    required this.assessmentTitle,
    required this.jobVacancyId,
    required this.jobTitle,
    required this.companyName,
    this.department = '',
    this.timeLimitMinutes = 60,
    this.questionCount = 1,
    this.passingThreshold = 60.0,
    this.status = 'Assigned',
    this.examScore = 0.0,
    this.finalWeightedScore = 0.0,
    this.isPassed = false,
    this.isSelectedForInterview = false,
    this.reviewerFeedback,
    this.assignedAt,
    this.startedAt,
    this.submittedAt,
    this.expiresAt,
    this.isExpired = false,
    this.isBlocked = false,
  });

  factory CandidateAssessmentListItem.fromJson(Map<String, dynamic> json) {
    return CandidateAssessmentListItem(
      submissionId: (json['submissionId'] ?? json['SubmissionId'])?.toString() ?? '',
      assessmentId: (json['assessmentId'] ?? json['AssessmentId'])?.toString() ?? '',
      assessmentTitle: (json['assessmentTitle'] ?? json['AssessmentTitle'])?.toString() ?? 'Technical Assessment',
      jobVacancyId: (json['jobVacancyId'] ?? json['JobVacancyId'])?.toString() ?? '',
      jobTitle: (json['jobTitle'] ?? json['JobTitle'])?.toString() ?? 'Technical Role',
      companyName: (json['companyName'] ?? json['CompanyName'])?.toString() ?? 'Verified Employer',
      department: (json['department'] ?? json['Department'])?.toString() ?? '',
      timeLimitMinutes: _asInt(json['timeLimitMinutes'] ?? json['TimeLimitMinutes'], 60),
      questionCount: _asInt(json['questionCount'] ?? json['QuestionCount'], 1),
      passingThreshold: _asDouble(json['passingThreshold'] ?? json['PassingThreshold'], 60.0),
      status: (json['status'] ?? json['Status'])?.toString() ?? 'Assigned',
      examScore: _asDouble(json['examScore'] ?? json['ExamScore'], 0.0),
      finalWeightedScore: _asDouble(json['finalWeightedScore'] ?? json['FinalWeightedScore'], 0.0),
      isPassed: json['isPassed'] == true || json['IsPassed'] == true,
      isSelectedForInterview: json['isSelectedForInterview'] == true || json['IsSelectedForInterview'] == true,
      reviewerFeedback: (json['reviewerFeedback'] ?? json['ReviewerFeedback'])?.toString(),
      assignedAt: _parseDateTime(json['assignedAt'] ?? json['AssignedAt']),
      startedAt: _parseDateTime(json['startedAt'] ?? json['StartedAt']),
      submittedAt: _parseDateTime(json['submittedAt'] ?? json['SubmittedAt']),
      expiresAt: _parseDateTime(json['expiresAt'] ?? json['ExpiresAt']),
      isExpired: json['isExpired'] == true || json['IsExpired'] == true,
      isBlocked: json['isBlocked'] == true || json['IsBlocked'] == true,
    );
  }

  final String submissionId;
  final String assessmentId;
  final String assessmentTitle;
  final String jobVacancyId;
  final String jobTitle;
  final String companyName;
  final String department;
  final int timeLimitMinutes;
  final int questionCount;
  final double passingThreshold;
  final String status;
  final double examScore;
  final double finalWeightedScore;
  final bool isPassed;
  final bool isSelectedForInterview;
  final String? reviewerFeedback;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final DateTime? expiresAt;
  final bool isExpired;
  final bool isBlocked;

  String get companyInitials {
    final trimmed = companyName.trim();
    if (trimmed.isEmpty) return 'CO';
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  bool get checkIsCompleted =>
      isSelectedForInterview ||
      status == 'Submitted' ||
      status == 'Under_Review' ||
      status == 'Graded' ||
      status == 'Passed' ||
      status == 'Rejected';

  bool get checkIsBlocked {
    if (checkIsCompleted || isSelectedForInterview) return false;
    return isBlocked ||
        status == 'Blocked' ||
        status == 'Started' ||
        status == 'In_Progress' ||
        startedAt != null;
  }

  bool get checkIsExpired {
    if (checkIsCompleted || checkIsBlocked) return false;
    return isExpired || (expiresAt != null && expiresAt!.isBefore(DateTime.now()));
  }

  bool get isUnderReview =>
      status == 'Under_Review' || (status == 'Submitted' && examScore == 0);

  bool get isGraded =>
      status == 'Graded' ||
      status == 'Passed' ||
      status == 'Rejected' ||
      (status == 'Submitted' && examScore > 0);

  bool get isActionRequired => !checkIsCompleted && !checkIsBlocked && !checkIsExpired;

  static int _asInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  static double _asDouble(dynamic v, double fallback) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static DateTime? _parseDateTime(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}

class AssessmentSubmissionDetail {
  const AssessmentSubmissionDetail({
    required this.id,
    required this.assessmentId,
    required this.assessmentTitle,
    this.jobTitle,
    this.companyName,
    this.department,
    this.examScore = 0.0,
    this.cvScore = 0.0,
    this.finalWeightedScore = 0.0,
    this.passingThreshold = 60.0,
    this.status = 'Assigned',
    this.startedAt,
    this.submittedAt,
    this.gradedAt,
    this.isSelectedForInterview = false,
    this.reviewerFeedback,
    this.isHired = false,
  });

  factory AssessmentSubmissionDetail.fromJson(Map<String, dynamic> json) {
    return AssessmentSubmissionDetail(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      assessmentId: (json['assessmentId'] ?? json['AssessmentId'])?.toString() ?? '',
      assessmentTitle: (json['assessmentTitle'] ?? json['AssessmentTitle'])?.toString() ?? 'Technical Assessment',
      jobTitle: (json['jobTitle'] ?? json['JobTitle'])?.toString(),
      companyName: (json['companyName'] ?? json['CompanyName'])?.toString(),
      department: (json['department'] ?? json['Department'])?.toString(),
      examScore: CandidateAssessmentListItem._asDouble(json['examScore'] ?? json['ExamScore'], 0.0),
      cvScore: CandidateAssessmentListItem._asDouble(json['cvScore'] ?? json['CvScore'], 0.0),
      finalWeightedScore: CandidateAssessmentListItem._asDouble(json['finalWeightedScore'] ?? json['FinalWeightedScore'], 0.0),
      passingThreshold: CandidateAssessmentListItem._asDouble(json['passingThreshold'] ?? json['PassingThreshold'], 60.0),
      status: (json['status'] ?? json['Status'])?.toString() ?? 'Assigned',
      startedAt: CandidateAssessmentListItem._parseDateTime(json['startedAt'] ?? json['StartedAt']),
      submittedAt: CandidateAssessmentListItem._parseDateTime(json['submittedAt'] ?? json['SubmittedAt']),
      gradedAt: CandidateAssessmentListItem._parseDateTime(json['gradedAt'] ?? json['GradedAt']),
      isSelectedForInterview: json['isSelectedForInterview'] == true || json['IsSelectedForInterview'] == true,
      reviewerFeedback: (json['reviewerFeedback'] ?? json['ReviewerFeedback'])?.toString(),
      isHired: json['isHired'] == true || json['IsHired'] == true,
    );
  }

  final String id;
  final String assessmentId;
  final String assessmentTitle;
  final String? jobTitle;
  final String? companyName;
  final String? department;
  final double examScore;
  final double cvScore;
  final double finalWeightedScore;
  final double passingThreshold;
  final String status;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  final DateTime? gradedAt;
  final bool isSelectedForInterview;
  final String? reviewerFeedback;
  final bool isHired;
}
