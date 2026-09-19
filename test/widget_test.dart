import 'package:flutter_test/flutter_test.dart';
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
  });

  test('selects the greeting from the local time', () {
    expect(candidateGreeting(DateTime(2026, 1, 1, 8)), 'Good Morning');
    expect(candidateGreeting(DateTime(2026, 1, 1, 13)), 'Good Afternoon');
    expect(candidateGreeting(DateTime(2026, 1, 1, 19)), 'Good Evening');
    expect(candidateGreeting(DateTime(2026, 1, 1, 23)), 'Good Night');
  });
}
