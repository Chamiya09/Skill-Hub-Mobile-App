import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_hub_mobile_app/components/skill_hub_loading_indicator.dart';
import 'package:skill_hub_mobile_app/config/api_config.dart';
import 'package:skill_hub_mobile_app/models/auth_session.dart';
import 'package:skill_hub_mobile_app/models/job.dart';
import 'package:skill_hub_mobile_app/screens/auth/loading_screen.dart';
import 'package:skill_hub_mobile_app/screens/candidate/candidate_main_scaffold.dart';

void main() {
  testWidgets('shows the animated SkillHub loading state', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoadingScreen()));

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Loading SkillHub',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
    expect(find.text('SkillHub'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 450));
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the SkillHub animation for assessment loading', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SkillHubLoadingIndicator(
              message: 'Loading assigned technical assessments...',
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Loading assigned technical assessments...'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.auto_awesome_outlined), findsOneWidget);
    expect(find.text('SkillHub'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 450));
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps all account options and profile details', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AccountScreen(
          user: const CandidateUser(
            id: 'candidate-1',
            fullName: 'Alex Morgan',
            email: 'alex@example.com',
            role: 'CANDIDATE',
          ),
          token: 'test-token',
          onLogout: () async {},
          onOpenAssessments: () {},
        ),
      ),
    );

    expect(find.text('Alex Morgan'), findsOneWidget);
    expect(find.text('alex@example.com'), findsOneWidget);
    expect(find.text('VERIFIED CANDIDATE'), findsOneWidget);
    expect(find.text('My Digital CV'), findsOneWidget);
    expect(find.text('Study Dashboard'), findsOneWidget);
    expect(find.text('Applied Jobs'), findsOneWidget);
    expect(find.text('Saved Jobs'), findsOneWidget);
    expect(find.text('Sign out of Skill Hub'), findsOneWidget);
  });

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
      'deadline': DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
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

  test('builds an API endpoint correctly using configured environment host', () {
    final endpoint = ApiConfig.endpoint(
      'public/jobs',
      queryParameters: {'limit': '6'},
    );

    expect(endpoint.path.endsWith('public/jobs'), isTrue);
    expect(endpoint.queryParameters, {'limit': '6'});
  });
}
