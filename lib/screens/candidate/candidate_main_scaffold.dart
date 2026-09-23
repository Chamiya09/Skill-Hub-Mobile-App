import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/auth_session.dart';
import 'applied_jobs_screen.dart';
import 'saved_jobs_screen.dart';
import 'candidate_home_screen.dart';
import 'digital_cv_screen.dart';
import '../../services/interview_prep_service.dart';

const Color _emerald = Color(0xFF10B981);
const Color _emeraldDark = Color(0xFF047857);
const Color _darkText = Color(0xFF1F2937);
const Color _mutedText = Color(0xFF9CA3AF);

String candidateGreeting(DateTime time) {
  final hour = time.hour;
  if (hour >= 5 && hour < 12) return 'Good Morning';
  if (hour >= 12 && hour < 17) return 'Good Afternoon';
  if (hour >= 17 && hour < 22) return 'Good Evening';
  return 'Good Night';
}

class CandidateMainScaffold extends StatefulWidget {
  const CandidateMainScaffold({
    super.key,
    required this.user,
    required this.token,
    required this.onLogout,
  });

  final CandidateUser user;
  final String token;
  final Future<void> Function() onLogout;

  @override
  State<CandidateMainScaffold> createState() => _CandidateMainScaffoldState();
}

class _CandidateMainScaffoldState extends State<CandidateMainScaffold> {
  int _selectedIndex = 0;
  DateTime _currentTime = DateTime.now();
  Timer? _greetingTimer;

  @override
  void initState() {
    super.initState();
    _greetingTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _greetingTimer?.cancel();
    super.dispose();
  }

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const HomeScreen(),
      const AssessmentsScreen(),
      const InterviewsScreen(),
      AccountScreen(
        user: widget.user,
        token: widget.token,
        onLogout: widget.onLogout,
        onOpenAssessments: () => _selectTab(1),
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 72,
        titleSpacing: 16,
        title: _CreativeTopTitle(
          pageIndex: _selectedIndex,
          greeting: candidateGreeting(_currentTime),
          firstName: widget.user.firstName,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Notifications',
              onPressed: () {},
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: _darkText,
                    size: 27,
                  ),
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D0F172A),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _selectTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: _emerald,
            unselectedItemColor: _mutedText,
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment_rounded),
                label: 'Assessment',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_month_rounded),
                label: 'Interviews',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreativeTopTitle extends StatelessWidget {
  const _CreativeTopTitle({
    required this.pageIndex,
    required this.greeting,
    required this.firstName,
  });

  final int pageIndex;
  final String greeting;
  final String firstName;

  static const _pages = [
    (Icons.assignment_rounded, 'Assessments', 'Show what you can do'),
    (Icons.calendar_month_rounded, 'Interviews', 'Your next conversations'),
    (Icons.person_rounded, 'My Account', 'Profile, activity & security'),
  ];

  @override
  Widget build(BuildContext context) {
    if (pageIndex == 0) {
      return Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3310B981),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.waving_hand_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting.toUpperCase(),
                  style: const TextStyle(
                    color: _emerald,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  firstName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final page = _pages[pageIndex - 1];
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3310B981),
                blurRadius: 12,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Icon(page.$1, color: Colors.white, size: 21),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page.$3.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _emerald,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                page.$2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AssessmentsScreen extends StatelessWidget {
  const AssessmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScreen(
      icon: Icons.assignment_outlined,
      title: 'Assessments',
      description: 'View assigned assessments and track your results.',
    );
  }
}

class InterviewsScreen extends StatelessWidget {
  const InterviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PlaceholderScreen(
      icon: Icons.calendar_today_outlined,
      title: 'Interviews',
      description: 'View scheduled and AI mock interviews.',
    );
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
    required this.user,
    required this.token,
    required this.onLogout,
    required this.onOpenAssessments,
  });

  final CandidateUser user;
  final String token;
  final Future<void> Function() onLogout;
  final VoidCallback onOpenAssessments;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      children: [
        const Text(
          'My Account',
          style: TextStyle(
            color: _darkText,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Manage your career profile and job activity.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 31,
                backgroundColor: const Color(0xFFECFDF5),
                child: Text(
                  user.firstName.characters.first.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF047857),
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _darkText,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'VERIFIED CANDIDATE',
                        style: TextStyle(
                          color: Color(0xFF047857),
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'CAREER CENTER',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        _AccountMenuCard(
          icon: Icons.badge_outlined,
          title: 'My Digital CV',
          subtitle: 'Manage your verified professional profile',
          onTap: () => _open(context, DigitalCvScreen(token: token)),
        ),
        const SizedBox(height: 10),
        _AccountMenuCard(
          icon: Icons.school_outlined,
          title: 'Study Dashboard',
          subtitle: 'Prepare for assessments and interviews',
          onTap: () => _open(context, _StudyDashboardPage(token: token)),
        ),
        const SizedBox(height: 10),
        _AccountMenuCard(
          icon: Icons.work_outline_rounded,
          title: 'Applied Jobs',
          subtitle: 'Track your submitted job applications',
          onTap: () => _open(
            context,
            AppliedJobsScreen(
              token: token,
              onOpenAssessments: () {
                Navigator.of(context).pop();
                onOpenAssessments();
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        _AccountMenuCard(
          icon: Icons.bookmark_border_rounded,
          title: 'Saved Jobs',
          subtitle: 'Review opportunities you saved for later',
          onTap: () => _open(context, SavedJobsScreen(token: token)),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onLogout,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
            backgroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFFFECACA)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          icon: const Icon(Icons.logout_rounded, size: 19),
          label: const Text(
            'Sign out of Skill Hub',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _AccountMenuCard extends StatelessWidget {
  const _AccountMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF047857), size: 22),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _darkText,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudyDashboardPage extends StatefulWidget {
  const _StudyDashboardPage({required this.token});

  final String token;

  @override
  State<_StudyDashboardPage> createState() => _StudyDashboardPageState();
}

class _StudyDashboardPageState extends State<_StudyDashboardPage> {
  late final InterviewPrepService _studyService;
  late Future<List<InterviewPrepGuide>> _guidesFuture;
  int _selectedRoleIndex = 0;

  @override
  void initState() {
    super.initState();
    _studyService = InterviewPrepService();
    _guidesFuture = _studyService.getMyGuides(widget.token);
  }

  @override
  void dispose() {
    _studyService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 76,
        leadingWidth: 62,
        titleSpacing: 10,
        shape: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        leading: Padding(
          padding: const EdgeInsets.only(left: 14, top: 14, bottom: 14),
          child: Material(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF334155),
                  size: 21,
                ),
              ),
            ),
          ),
        ),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'LEARNING HUB',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _emerald,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Study Dashboard',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _darkText,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 11),
            _StudyTitleIcon(),
          ],
        ),
      ),
      body: FutureBuilder<List<InterviewPrepGuide>>(
        future: _guidesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _emerald),
            );
          }
          if (snapshot.hasError) {
            return _StudyDataState(
              icon: Icons.cloud_off_rounded,
              title: 'Unable to load study guides',
              message: 'Check your connection and try again.',
              actionLabel: 'Try again',
              onAction: () => setState(
                () => _guidesFuture = _studyService.getMyGuides(widget.token),
              ),
            );
          }
          final guides = snapshot.data ?? const <InterviewPrepGuide>[];
          if (guides.isEmpty) {
            return const _StudyDataState(
              icon: Icons.menu_book_outlined,
              title: 'No study guides yet',
              message: 'Role-specific guidelines will appear here when an interview preparation guide is generated for your application.',
            );
          }
          final safeIndex = _selectedRoleIndex < guides.length
              ? _selectedRoleIndex
              : 0;
          if (safeIndex != _selectedRoleIndex) {
            _selectedRoleIndex = safeIndex;
          }
          return RefreshIndicator(
            color: _emerald,
            onRefresh: () async {
              setState(
                () => _guidesFuture = _studyService.getMyGuides(widget.token),
              );
              await _guidesFuture;
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
              children: [
                const _StudyWelcomeCard(),
                const SizedBox(height: 16),
                const _StudySectionLabel(
                  label: 'ROLE-BASED STUDY GUIDES',
                  caption: 'Choose a saved job guide from your database',
                ),
                const SizedBox(height: 10),
                _StudyRoleSelector(
                  guides: guides,
                  selectedIndex: safeIndex,
                  onSelected: (index) =>
                      setState(() => _selectedRoleIndex = index),
                ),
                const SizedBox(height: 12),
                _StudyRoleGuidelines(guide: guides[safeIndex]),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StudyRoleSelector extends StatelessWidget {
  const _StudyRoleSelector({
    required this.guides,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<InterviewPrepGuide> guides;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 43,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: guides.length,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final guide = guides[index];
        final selected = index == selectedIndex;
        return ChoiceChip(
          selected: selected,
          onSelected: (_) => onSelected(index),
          avatar: Icon(
            Icons.work_outline_rounded,
            size: 16,
            color: selected ? Colors.white : _emeraldDark,
          ),
          label: Text(guide.displayRole),
          labelStyle: TextStyle(
            color: selected ? Colors.white : _darkText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          selectedColor: _emeraldDark,
          backgroundColor: Colors.white,
          side: BorderSide(
            color: selected ? _emeraldDark : const Color(0xFFE2E8F0),
          ),
          showCheckmark: false,
          padding: const EdgeInsets.symmetric(horizontal: 8),
        );
      },
    ),
  );
}

class _StudyRoleGuidelines extends StatelessWidget {
  const _StudyRoleGuidelines({required this.guide});

  final InterviewPrepGuide guide;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _StudyRolePanel(
        icon: Icons.menu_book_outlined,
        eyebrow: 'THEORETICAL MAIN CONCEPTS',
        title: '${guide.displayRole} foundations to master',
        areas: guide.theoreticalAreas,
      ),
      const SizedBox(height: 10),
      _StudyRolePanel(
        icon: Icons.code_rounded,
        eyebrow: 'PRACTICAL IMPLEMENTATION',
        title: '${guide.displayRole} workflows to practice',
        areas: guide.practicalAreas,
      ),
      const SizedBox(height: 10),
      _StudyRolePanel(
        icon: Icons.lightbulb_outline_rounded,
        eyebrow: 'CAREER COACH STRATEGY',
        title: 'How to communicate your ${guide.displayRole} experience',
        points: guide.proTips,
      ),
    ],
  );
}

class _StudyRolePanel extends StatelessWidget {
  const _StudyRolePanel({
    required this.icon,
    required this.eyebrow,
    required this.title,
    this.areas = const [],
    this.points = const [],
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final List<StudyFocusArea> areas;
  final List<String> points;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: _emeraldDark, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow,
                    style: const TextStyle(
                      color: _emeraldDark,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: const TextStyle(
                      color: _darkText,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...areas.expand(
          (area) => [
            if (area.priority?.isNotEmpty == true ||
                area.estimatedStudyTime?.isNotEmpty == true)
              Text(
                [
                  if (area.priority?.isNotEmpty == true) area.priority!,
                  if (area.estimatedStudyTime?.isNotEmpty == true)
                    area.estimatedStudyTime!,
                ].join(' • '),
                style: const TextStyle(
                  color: _emeraldDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (area.overview?.isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Text(
                  area.overview!,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ...area.conceptsToReview.map(
              (concept) => _StudyBullet(text: concept),
            ),
            if (area.practicalApplication?.isNotEmpty == true)
              _StudyBullet(text: area.practicalApplication!),
            if (area.coachTip?.isNotEmpty == true)
              _StudyBullet(text: area.coachTip!),
            const SizedBox(height: 6),
          ],
        ),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6, right: 8),
                  child: Icon(Icons.circle, color: _emerald, size: 5),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _StudyDataState extends StatelessWidget {
  const _StudyDataState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _emerald, size: 48),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _darkText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(backgroundColor: _emeraldDark),
            ),
          ],
        ],
      ),
    ),
  );
}

class _StudyBullet extends StatelessWidget {
  const _StudyBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6, right: 8),
          child: Icon(Icons.circle, color: _emerald, size: 5),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

class _StudyWelcomeCard extends StatelessWidget {
  const _StudyWelcomeCard();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF047857), Color(0xFF10B981)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x3310B981),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0x26FFFFFF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 25,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Build momentum',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Use these guidelines to turn each application into a stronger opportunity.',
                style: TextStyle(
                  color: Color(0xE6FFFFFF),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StudySectionLabel extends StatelessWidget {
  const _StudySectionLabel({required this.label, required this.caption});

  final String label;
  final String caption;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: _emeraldDark,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        caption,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
      ),
    ],
  );
}

class _StudyTitleIcon extends StatelessWidget {
  const _StudyTitleIcon();

  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [_emerald, Color(0xFF047857)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(13),
      boxShadow: const [
        BoxShadow(
          color: Color(0x3310B981),
          blurRadius: 12,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: const Icon(Icons.school_outlined, color: Colors.white, size: 21),
  );
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _emerald.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: _emerald, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: _darkText,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
