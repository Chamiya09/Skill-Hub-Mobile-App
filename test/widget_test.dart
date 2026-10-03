import 'package:flutter_test/flutter_test.dart';
import 'package:skill_hub_mobile_app/config/api_config.dart';
import 'package:skill_hub_mobile_app/models/job.dart';
import 'package:skill_hub_mobile_app/screens/candidate/candidate_main_scaffold.dart';

void main() {
  test('maps the public jobs API response', () {
    final job = Job.fromJson({
      'id': 'job-1',
      'companyId': 'company-1',
      'companyName': 'Skill Hub Labs',
      'title': 'Flutter Developer',
      'department': 'Engineering',
      'location': 'Colombo',
      'employmentType': 'Full-time',
      'experienceLevel': 'Mid Level',
      'salaryRange': 'LKR 200K - 300K',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    });

    expect(job.title, 'Flutter Developer');
    expect(job.companyInitials, 'SH');
    expect(job.detailTags, ['Engineering', 'Mid Level']);
    expect(job.salaryLabel, 'LKR 200K - 300K');
    expect(job.deadline, isNull);
    expect(job.isDeadlinePassed, isFalse);
  });

  test('parses active and expired job deadlines correctly', () {
    final activeJob = Job.fromJson({
      'id': 'job-2',
      'title': 'Backend Developer',
      'deadline': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
    });
    expect(activeJob.deadline, isNotNull);
    expect(activeJob.isDeadlinePassed, isFalse);
    expect(activeJob.formattedDeadline, isNotNull);

    final expiredJob = Job.fromJson({
      'id': 'job-3',
      'title': 'Frontend Developer',
      'deadline': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    });
    expect(expiredJob.deadline, isNotNull);
    expect(expiredJob.isDeadlinePassed, isTrue);
    expect(expiredJob.deadlineLabel, 'Deadline Passed');
  });

  test('selects the greeting from the local time', () {
    expect(candidateGreeting(DateTime(2026, 1, 1, 8)), 'Good Morning');
    expect(candidateGreeting(DateTime(2026, 1, 1, 13)), 'Good Afternoon');
    expect(candidateGreeting(DateTime(2026, 1, 1, 19)), 'Good Evening');
    expect(candidateGreeting(DateTime(2026, 1, 1, 23)), 'Good Night');
  });

  test('builds an Android emulator API endpoint outside web', () {
    final endpoint = ApiConfig.endpoint(
      'public/jobs',
      queryParameters: {'limit': '6'},
    );

    expect(
      endpoint.toString(),
      'http://10.0.2.2:5155/api/public/jobs?limit=6',
    );
  });
}
