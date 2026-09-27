class CandidateInterview {
  const CandidateInterview({
    required this.id,
    required this.title,
    this.jobVacancyId,
    this.jobTitle = 'Technical Interview',
    this.companyName = 'Skill-Hub Partner',
    this.department,
    required this.eventDate,
    required this.eventTime,
    this.meetingMode = 'Online',
    this.location,
    this.description,
    this.status = 'Upcoming',
    this.isHired = false,
    this.hiredMessage,
    this.createdAt,
  });

  factory CandidateInterview.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? json['Status'])?.toString() ?? 'Upcoming';
    final isHiredFlag = json['isHired'] == true ||
        json['IsHired'] == true ||
        statusStr.trim().toLowerCase() == 'hired' ||
        ((json['description'] ?? json['Description'])?.toString().contains('[HIRED]') ?? false);

    return CandidateInterview(
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      title: (json['title'] ?? json['Title'])?.toString() ?? 'Technical Interview',
      jobVacancyId: (json['jobVacancyId'] ?? json['JobVacancyId'])?.toString(),
      jobTitle: (json['jobTitle'] ?? json['JobTitle'])?.toString() ?? 'Technical Interview',
      companyName: (json['companyName'] ?? json['CompanyName'])?.toString() ?? 'Skill-Hub Partner',
      department: (json['department'] ?? json['Department'])?.toString(),
      eventDate: (json['eventDate'] ?? json['EventDate'])?.toString() ?? '',
      eventTime: (json['eventTime'] ?? json['EventTime'])?.toString() ?? '',
      meetingMode: (json['meetingMode'] ?? json['MeetingMode'])?.toString() ?? 'Online',
      location: (json['location'] ?? json['Location'])?.toString(),
      description: (json['description'] ?? json['Description'])?.toString(),
      status: isHiredFlag ? 'Hired' : statusStr,
      isHired: isHiredFlag,
      hiredMessage: (json['hiredMessage'] ?? json['HiredMessage'])?.toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? json['CreatedAt'])?.toString() ?? ''),
    );
  }

  final String id;
  final String title;
  final String? jobVacancyId;
  final String jobTitle;
  final String companyName;
  final String? department;
  final String eventDate;
  final String eventTime;
  final String meetingMode;
  final String? location;
  final String? description;
  final String status;
  final bool isHired;
  final String? hiredMessage;
  final DateTime? createdAt;

  bool get isOnline => meetingMode.trim().toLowerCase() == 'online';
  bool get isOffer => meetingMode.trim().toLowerCase() == 'offer';

  bool get hasValidUrl {
    if (location == null) return false;
    final loc = location!.trim().toLowerCase();
    return loc.startsWith('http://') ||
        loc.startsWith('https://') ||
        loc.contains('meet.google.com') ||
        loc.contains('zoom.us') ||
        loc.contains('teams.microsoft.com');
  }

  String? get joinUrl {
    if (location == null || location!.trim().isEmpty) return null;
    final loc = location!.trim();
    if (loc.startsWith('http://') || loc.startsWith('https://')) {
      return loc;
    }
    return 'https://$loc';
  }

  String get formattedDisplayDate {
    if (eventDate.isEmpty) return 'Date to be confirmed';
    try {
      final parts = eventDate.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final dt = DateTime(year, month, day);
        const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
          'Dec'
        ];
        final weekday = weekdays[dt.weekday - 1];
        final monthName = months[dt.month - 1];
        return '$weekday, $monthName $day, $year';
      }
    } catch (_) {}
    return eventDate;
  }

  String get formattedTimeSlot {
    if (eventTime.isEmpty) return 'Time slot to be confirmed';
    final parts = eventTime.contains(' - ') ? eventTime.split(' - ') : [eventTime];
    final formatted = parts.map((p) {
      final trimmed = p.trim();
      final sub = trimmed.split(':');
      if (sub.length >= 2) {
        final h = int.tryParse(sub[0]);
        final m = int.tryParse(sub[1]);
        if (h != null && m != null) {
          final ampm = h >= 12 ? 'PM' : 'AM';
          final h12 = h % 12 == 0 ? 12 : h % 12;
          final minStr = m.toString().padLeft(2, '0');
          return '$h12:$minStr $ampm';
        }
      }
      return trimmed;
    });
    return formatted.join(' – ');
  }
}
