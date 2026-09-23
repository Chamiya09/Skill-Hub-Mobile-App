import 'package:flutter/material.dart';

import '../../models/candidate_application.dart';
import '../../services/candidate_applications_service.dart';
import 'find_jobs_screen.dart';

const _emerald = Color(0xFF10B981);
const _emeraldDark = Color(0xFF047857);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({
    super.key,
    required this.token,
    required this.onOpenAssessments,
  });
  final String token;
  final VoidCallback onOpenAssessments;

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  late final CandidateApplicationsService _service =
      CandidateApplicationsService(token: widget.token);
  List<CandidateApplication> _applications = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final applications = await _service.getMyApplications();
      if (mounted) setState(() => _applications = applications);
    } on CandidateApplicationsException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
                  border: Border.all(color: _border),
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
                    'APPLICATION TRACKER',
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
                    'Applied Jobs',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 11),
            _TitleIcon(),
          ],
        ),
        actions: const [SizedBox(width: 14)],
      ),
      body: RefreshIndicator(
        color: _emerald,
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
          children: [
            _Hero(count: _applications.length, onExplore: _openFindJobs),
            const SizedBox(height: 18),
            if (_error != null) _ErrorCard(message: _error!, onRetry: _load),
            if (_loading)
              ...List.generate(3, (_) => const _ApplicationSkeleton()),
            if (!_loading && _error == null && _applications.isEmpty)
              _EmptyState(onExplore: _openFindJobs),
            if (!_loading && _error == null)
              ..._applications.map(
                (application) => Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: _ApplicationCard(
                    application: application,
                    onTap: () => _showProgress(application),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openFindJobs() => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const FindJobsScreen()));

  Future<void> _showProgress(CandidateApplication application) async {
    final openAssessments = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _ProgressSheet(
        application: application,
        onOpenAssessments: () => Navigator.of(sheetContext).pop(true),
      ),
    );
    if (openAssessments == true && mounted) {
      widget.onOpenAssessments();
    }
  }
}

class _TitleIcon extends StatelessWidget {
  const _TitleIcon();
  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [_emerald, _emeraldDark],
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
      Icons.business_center_rounded,
      color: Colors.white,
      size: 21,
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.count, required this.onExplore});
  final int count;
  final VoidCallback onExplore;
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
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0x26FFFFFF),
            borderRadius: BorderRadius.circular(7),
          ),
          child: const Text(
            'APPLICATION TRACKER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
        ),
        const SizedBox(height: 11),
        const Text(
          'Applied Positions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -.6,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Review every application and open its complete hiring journey.',
          style: TextStyle(
            color: Color(0xE6FFFFFF),
            fontSize: 12.5,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0x26FFFFFF),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0x33FFFFFF)),
              ),
              child: Text(
                '$count active ${count == 1 ? 'application' : 'applications'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onExplore,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              icon: const Icon(Icons.search_rounded, size: 17),
              label: const Text(
                'Explore Jobs',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application, required this.onTap});
  final CandidateApplication application;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final stage = _stage(application.status);
    final rejected = _isRejected(application.status);
    final suspended = _isSuspended(application.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: application.companyLogoUrl?.isNotEmpty == true
                        ? Image.network(
                            application.companyLogoUrl!,
                            fit: BoxFit.cover,
                            width: 46,
                            height: 46,
                            errorBuilder: (_, _, _) =>
                                _Initials(application.companyInitials),
                          )
                        : _Initials(application.companyInitials),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.jobTitle,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          application.companyName,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(
                    label: rejected
                        ? 'Rejected'
                        : suspended
                        ? 'Suspended'
                        : _stages[stage],
                    rejected: rejected || suspended,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 7,
                children: [
                  _Meta(Icons.location_on_outlined, application.location),
                  _Meta(Icons.schedule_rounded, application.employmentType),
                  _Meta(
                    Icons.calendar_today_outlined,
                    _date(application.appliedDate),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              const Divider(height: 1, color: Color(0xFFEDF1F5)),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Open complete hiring journey',
                      style: TextStyle(
                        color: _muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: onTap,
                    style: FilledButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: _emeraldDark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.timeline_rounded, size: 16),
                    label: const Text(
                      'Track Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressSheet extends StatelessWidget {
  const _ProgressSheet({
    required this.application,
    required this.onOpenAssessments,
  });
  final CandidateApplication application;
  final VoidCallback onOpenAssessments;
  @override
  Widget build(BuildContext context) {
    final stage = _stage(application.status);
    final rejected = _isRejected(application.status);
    final suspended = _isSuspended(application.status);
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 14, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFF1FCF7)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  border: Border(bottom: BorderSide(color: Color(0xFFEDF1F5))),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFECFDF5), Color(0xFFF0FDFA)],
                        ),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: _Initials(application.companyInitials),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            application.jobTitle,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 7),
                          _StatusBadge(
                            label: rejected
                                ? 'Rejected'
                                : suspended
                                ? 'Assessment Suspended'
                                : _stages[stage],
                            rejected: rejected || suspended,
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 10,
                            runSpacing: 6,
                            children: [
                              _Meta(
                                Icons.business_outlined,
                                application.companyName,
                              ),
                              _Meta(
                                Icons.location_on_outlined,
                                application.location,
                              ),
                              _Meta(
                                Icons.schedule_rounded,
                                application.employmentType,
                              ),
                              _Meta(
                                Icons.calendar_today_outlined,
                                'Applied ${_date(application.appliedDate)}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        side: const BorderSide(color: _border),
                        backgroundColor: Colors.white,
                      ),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: _muted,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'APPLICATION JOURNEY',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .8,
                      ),
                    ),
                    const SizedBox(height: 13),
                    _JourneyStepper(
                      stage: stage,
                      rejected: rejected,
                      suspended: suspended,
                    ),
                    const SizedBox(height: 20),
                    _CopilotInsight(
                      message: _copilotMessage(
                        stage,
                        rejected: rejected,
                        suspended: suspended,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 22),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFBFCFD), Color(0xFFF4FBF8)],
                  ),
                  border: Border(top: BorderSide(color: Color(0xFFEDF1F5))),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onOpenAssessments,
                        style: FilledButton.styleFrom(
                          backgroundColor: _emerald,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(
                          Icons.assignment_turned_in_rounded,
                          size: 18,
                        ),
                        label: const Text(
                          'Assessment Results',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _stages = [
  'Applied',
  'Review',
  'Shortlist',
  'Assessment',
  'Interview',
  'Offer',
];
int _stage(String status) {
  final value = status.toLowerCase();
  if (value.contains('offer') || value.contains('hired')) return 5;
  if (value.contains('interview')) return 4;
  if (value.contains('assess') || value.contains('test')) return 3;
  if (value.contains('shortlist')) return 2;
  if (value.contains('review') || value.contains('screen')) return 1;
  return 0;
}

bool _isRejected(String status) {
  final value = status.toLowerCase();
  return value.contains('reject');
}

bool _isSuspended(String status) {
  final value = status.toLowerCase();
  return value.contains('suspend') || value.contains('block');
}

String _copilotMessage(
  int stage, {
  required bool rejected,
  required bool suspended,
}) {
  if (rejected) {
    return 'Your application was not selected to proceed after the shortlisting review. Thank you for your interest and time.';
  }
  if (suspended) {
    return 'Your technical assessment was suspended because the test session rules were not followed. This assessment cannot be retaken.';
  }
  return [
    'Your application is submitted. Keep your Digital CV current while the hiring team begins its review.',
    'Your profile is being reviewed. Prepare two measurable examples that demonstrate impact in this role.',
    'You made the shortlist. A technical assessment may be dispatched by the hiring committee.',
    'Your technical assessment has been sent by HR. Head to Technical Assessments to take your coding challenge.',
    'Your interview stage is active. Rehearse concise STAR responses and questions for the hiring team.',
    'You reached the offer stage. Review the role scope, total package, and growth expectations carefully.',
  ][stage];
}

String _date(DateTime? date) {
  if (date == null) return 'Recently';
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
    'Dec',
  ];
  final local = date.toLocal();
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}

class _JourneyStepper extends StatelessWidget {
  const _JourneyStepper({
    required this.stage,
    required this.rejected,
    required this.suspended,
  });
  final int stage;
  final bool rejected;
  final bool suspended;

  @override
  Widget build(BuildContext context) {
    final failedIndex = rejected
        ? 2
        : suspended
        ? 3
        : -1;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 15),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDF1F5)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_stages.length, (index) {
            final complete = failedIndex >= 0
                ? index < failedIndex
                : index <= stage;
            final current = failedIndex >= 0
                ? index == failedIndex
                : index == stage;
            final failed = index == failedIndex;
            final color = failed
                ? const Color(0xFFEF4444)
                : complete
                ? _emerald
                : const Color(0xFFDBE3EC);
            return SizedBox(
              width: index == _stages.length - 1 ? 72 : 105,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: complete || failed ? color : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                          boxShadow: current
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: .18),
                                    spreadRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: complete || failed
                            ? Icon(
                                failed
                                    ? Icons.close_rounded
                                    : Icons.check_rounded,
                                color: Colors.white,
                                size: 15,
                              )
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                      if (index < _stages.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            color:
                                index < (failedIndex >= 0 ? failedIndex : stage)
                                ? _emerald
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Text(
                    _stages[index],
                    style: TextStyle(
                      color: failed
                          ? const Color(0xFFDC2626)
                          : current
                          ? _ink
                          : const Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: current ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _CopilotInsight extends StatelessWidget {
  const _CopilotInsight({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFF5F7FF), Color(0xFFF8FAFC)],
      ),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFFC7D2FE)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Color(0xFF6366F1),
            size: 17,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI COPILOT INSIGHT',
                style: TextStyle(
                  color: Color(0xFF3730A3),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.rejected});
  final String label;
  final bool rejected;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: rejected ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: rejected ? const Color(0xFFDC2626) : _emeraldDark,
        fontSize: 9,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _Initials extends StatelessWidget {
  const _Initials(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text.isEmpty ? 'SH' : text,
    style: const TextStyle(
      color: _emeraldDark,
      fontSize: 14,
      fontWeight: FontWeight.w900,
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text);
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: _muted, size: 14),
      const SizedBox(width: 4),
      Text(
        text.isEmpty ? 'Not specified' : text,
        style: const TextStyle(color: _muted, fontSize: 10.5),
      ),
    ],
  );
}

class _ApplicationSkeleton extends StatelessWidget {
  const _ApplicationSkeleton();
  @override
  Widget build(BuildContext context) => Container(
    height: 210,
    margin: const EdgeInsets.only(bottom: 13),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFF1F5F9)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: const Center(
      child: CircularProgressIndicator(color: _emerald, strokeWidth: 2.3),
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      border: Border.all(color: const Color(0xFFFECACA)),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12),
        ),
        const SizedBox(height: 9),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onExplore});
  final VoidCallback onExplore;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(30),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            color: Color(0xFFECFDF5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.business_center_outlined,
            color: _emeraldDark,
          ),
        ),
        const SizedBox(height: 15),
        const Text(
          'No Job Applications Yet',
          style: TextStyle(
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'Browse verified opportunities and apply in one click with your Digital CV.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 15),
        FilledButton.icon(
          onPressed: onExplore,
          style: FilledButton.styleFrom(backgroundColor: _emerald),
          icon: const Icon(Icons.search_rounded, size: 18),
          label: const Text('Find Opportunities'),
        ),
      ],
    ),
  );
}
