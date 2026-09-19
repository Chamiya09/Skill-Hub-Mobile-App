import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_hub_mobile_app/models/company_profile.dart';
import 'package:skill_hub_mobile_app/models/job_vacancy.dart';
import 'package:skill_hub_mobile_app/models/pipeline_candidate.dart';
import 'package:skill_hub_mobile_app/screens/hr_pages/screening_pipeline_page.dart';
import 'package:skill_hub_mobile_app/services/ai_pipeline_service.dart';
import 'package:skill_hub_mobile_app/screens/hr_pages/company_profile_screen.dart';
import 'package:skill_hub_mobile_app/screens/hr_pages/job_details_page.dart';
import 'package:skill_hub_mobile_app/screens/hr_pages/job_form_page.dart';
import 'package:skill_hub_mobile_app/screens/hr_pages/jobs_page.dart';
import 'package:skill_hub_mobile_app/screens/hr_pages/security_screen.dart';
import 'package:skill_hub_mobile_app/services/company_account_service.dart';
import 'package:skill_hub_mobile_app/services/jobs_service.dart';
import 'package:skill_hub_mobile_app/widgets/hr_mobile_ui.dart';

const job = JobVacancy(
  id: 'job-1',
  title: 'Senior Enterprise Platform Engineer',
  department: 'Engineering',
  location: 'Colombo, Sri Lanka - Hybrid regional office',
  employmentType: 'Full-time',
  experienceLevel: 'Principal (10+ years)',
  status: 'Active',
  description: 'Design and maintain enterprise systems.',
  applicantsCount: 125,
  salaryRange: 'LKR 300,000 - 600,000 per month',
  whatWeOffer: 'Flexible hours\nHealth insurance',
);

class _Jobs extends JobsService {
  @override
  Future<List<JobVacancy>> getJobs() async => [job];
}

const candidate = PipelineCandidate(
  applicationId: 'application-1',
  candidateId: 'candidate-1',
  name: 'Alexandra Enterprise Candidate',
  email: 'alexandra@example.test',
  headline: 'Senior software engineer and platform architect',
  location: 'Colombo, Sri Lanka',
  status: 'Applied',
  aiScore: 94,
  skills: ['Flutter', 'Dart', 'Testing', 'APIs', 'Cloud architecture'],
);

class _Pipeline extends AiPipelineService {
  @override
  Future<List<PipelineCandidate>> getRankedApplicants(String jobId) async => [
    candidate,
  ];
}

class _Account extends CompanyAccountService {
  final profile = CompanyProfile.fromJson({
    'companyName': 'Example Enterprise',
    'adminName': 'Sample Admin',
    'contactEmail': 'hr@example.test',
    'phone': '+94 11 123 4567',
    'companySize': 'Custom company size',
    'industry': 'Custom industry',
    'foundedYear': '2010',
    'location': 'Colombo',
    'logoUrl': '',
    'website': 'https://example.test',
    'linkedinUrl': 'https://example.test/linkedin',
    'twitterUrl': 'https://example.test/twitter',
    'githubUrl': 'https://example.test/github',
    'about': 'An enterprise team building useful software.',
  });
  CompanyProfile? saved;
  @override
  Future<CompanyProfile> getProfile() async => profile;
  @override
  Future<CompanyProfile> updateProfile(CompanyProfile profile) async {
    saved = profile;
    return profile;
  }
}

Future<void> mount(
  WidgetTester tester,
  Widget child, {
  double width = 360,
  double scale = 1,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(useMaterial3: true),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: HrMobileTheme(child: Scaffold(body: child)),
    ),
  );
  await tester.pumpAndSettle();
}

Widget launcher(Widget child) => Builder(
  builder: (context) => Center(
    child: TextButton(
      onPressed: () => showHrSheet<void>(context, builder: (_) => child),
      child: const Text('Open'),
    ),
  ),
);

void main() {
  testWidgets(
    'pipeline selection and complete candidate details work on narrow screens',
    (tester) async {
      await mount(
        tester,
        ScreeningPipelinePage(
          jobsService: _Jobs(),
          pipelineService: _Pipeline(),
        ),
        width: 320,
        scale: 1.3,
      );
      final pageScroll = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
        find.text('Select candidates'),
        200,
        scrollable: pageScroll,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Select candidates'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CheckboxListTile));
      await tester.tap(find.text('Apply Selection'));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.text('Move 1 to shortlist'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('View Details'),
        200,
        scrollable: pageScroll,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();
      final detailScroll = find
          .descendant(
            of: find.byType(HrSheet),
            matching: find.byType(Scrollable),
          )
          .first;
      expect(find.text(candidate.name), findsWidgets);
      await tester.scrollUntilVisible(
        find.text(candidate.email),
        150,
        scrollable: detailScroll,
      );
      expect(find.text(candidate.email), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Cloud architecture'),
        150,
        scrollable: detailScroll,
      );
      expect(find.text('Cloud architecture'), findsOneWidget);
      expect(find.text('Done').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('job editor retains fields and keeps save above the keyboard', (
    tester,
  ) async {
    await mount(tester, launcher(const JobFormPage(job: job)));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Job Vacancy'), findsOneWidget);
    final scroll = find
        .descendant(of: find.byType(HrSheet), matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(
      find.text('What we offer'),
      200,
      scrollable: scroll,
    );
    expect(find.widgetWithText(TextFormField, 'What we offer'), findsOneWidget);
    expect(find.text('Save Changes').hitTestable(), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.getBottomRight(find.text('Save Changes')).dy, lessThan(500));
    expect(tester.takeException(), isNull);
  });

  testWidgets('long job details are readable at 320px and 1.6 text scale', (
    tester,
  ) async {
    await mount(
      tester,
      launcher(const JobDetailsPage(job: job)),
      width: 320,
      scale: 1.6,
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final scroll = find
        .descendant(of: find.byType(HrSheet), matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(
      find.text(job.salaryRange!),
      180,
      scrollable: scroll,
    );
    expect(find.text(job.salaryRange!), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Requisition Details'),
      180,
      scrollable: scroll,
    );
    expect(find.text('Requisition Details'), findsOneWidget);
    expect(find.text('Done').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'filter sheet cancels draft changes and applies only on confirmation',
    (tester) async {
      await mount(tester, JobsPage(service: _Jobs()));
      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      final sheet = find.byType(HrSheet);
      await tester.tap(
        find.descendant(
          of: sheet,
          matching: find.widgetWithText(FilterChip, 'Closed'),
        ),
      );
      await tester.tap(
        find.descendant(of: sheet, matching: find.byTooltip('Close')),
      );
      await tester.pumpAndSettle();
      expect(find.text(job.title), findsOneWidget);
      await tester.tap(find.text('Filters'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: sheet,
          matching: find.widgetWithText(FilterChip, 'Closed'),
        ),
      );
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();
      expect(find.text('No matching vacancies'), findsOneWidget);
      expect(find.text(job.title), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'profile modal preserves all values including custom dropdown values',
    (tester) async {
      final account = _Account();
      await mount(tester, CompanyProfileScreen(service: account));
      await tester.scrollUntilVisible(find.text('Edit Company Profile'), 400);
      await tester.tap(find.text('Edit Company Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Custom industry'), findsOneWidget);
      final field = find.widgetWithText(TextFormField, 'Company name');
      await tester.enterText(field, 'Updated Enterprise');
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();
      expect(account.saved!.companyName, 'Updated Enterprise');
      final expected = account.profile.toJson()
        ..['companyName'] = 'Updated Enterprise';
      expect(account.saved!.toJson(), expected);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('security editor validates without leaving the sheet', (
    tester,
  ) async {
    await mount(tester, const SecurityScreen(), width: 320);
    await tester.scrollUntilVisible(find.text('Change Password'), 200);
    await tester.tap(find.text('Change Password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(find.text('This field is required'), findsNWidgets(3));
    expect(find.byType(HrSheet), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
