import 'package:flutter/material.dart';

import '../../models/dashboard_stats.dart';
import '../../services/dashboard_service.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final _service = DashboardService();
  DashboardData? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final data = await _service.getOverview();
      if (mounted) setState(() => _data = data);
    } on DashboardException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to load company dashboard data.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _data == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      );
    }
    if (_data == null) return _ErrorState(message: _error!, onRetry: _load);

    final data = _data!;
    final stats = data.stats;
    return RefreshIndicator(
      color: const Color(0xFF10B981),
      onRefresh: _load,
      child: ListView(
        key: const PageStorageKey('overview-page'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          if (_error != null) ...[
            _InlineError(message: _error!, onRetry: _load),
            const SizedBox(height: 14),
          ],
          _OverviewHeader(companyName: data.companyName),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.18,
            children: [
              _MetricCard(
                'Active Vacancies',
                stats.activeVacanciesCount,
                'Live',
                Icons.work_outline_rounded,
              ),
              _MetricCard(
                'Total Candidates',
                stats.totalCandidatesCount,
                '+${stats.candidatesThisWeekCount} this week',
                Icons.groups_outlined,
              ),
              _MetricCard(
                'AI Shortlisted',
                stats.aiShortlistedCount,
                'High Matches',
                Icons.auto_awesome_rounded,
                accent: true,
              ),
              _MetricCard(
                'Pending Interviews',
                stats.pendingInterviewsCount,
                'Scheduled',
                Icons.schedule_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _TopMatches(matches: stats.topTalentMatches),
          const SizedBox(height: 18),
          _VacancyMetrics(vacancies: stats.vacancyMetrics),
          const SizedBox(height: 18),
          _PipelineHealth(stats: stats),
          const SizedBox(height: 18),
          _RecentActivity(stats: stats),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.companyName});
  final String companyName;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Colors.white, Color(0xFFECFDF5)]),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: Color(0xFF059669),
              size: 15,
            ),
            SizedBox(width: 6),
            Text(
              'TALENT INTELLIGENCE',
              style: TextStyle(
                color: Color(0xFF059669),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text(
          'Company Overview',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$companyName candidate velocity and hiring signals at a glance.',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
    this.label,
    this.value,
    this.note,
    this.icon, {
    this.accent = false,
  });
  final String label;
  final int value;
  final String note;
  final IconData icon;
  final bool accent;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: accent ? const Color(0xFFF0FDF4) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: accent ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: accent
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                size: 17,
                color: accent
                    ? const Color(0xFF047857)
                    : const Color(0xFF475569),
              ),
            ),
          ],
        ),
        const Spacer(),
        Text(
          '$value',
          style: TextStyle(
            color: accent ? const Color(0xFF047857) : const Color(0xFF0F172A),
            fontSize: 27,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          note,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: accent ? const Color(0xFF059669) : const Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _TopMatches extends StatelessWidget {
  const _TopMatches({required this.matches});
  final List<TopTalentMatch> matches;

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Top AI Talent Matches',
    subtitle: 'Highest recent scores across active roles',
    trailing: const _Badge('LIVE INTELLIGENCE'),
    child: matches.isEmpty
        ? const _Empty(
            'No AI-scored candidates yet. Run AI Screening to populate this list.',
          )
        : Column(
            children: matches.asMap().entries.map((entry) {
              final match = entry.value;
              final initials = match.candidateName
                  .split(RegExp(r'\s+'))
                  .where((part) => part.isNotEmpty)
                  .map((part) => part[0])
                  .take(2)
                  .join()
                  .toUpperCase();
              return _ListDivider(
                last: entry.key == matches.length - 1,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFD1FAE5),
                      foregroundColor: const Color(0xFF047857),
                      child: Text(
                        initials.isEmpty ? 'CA' : initials,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.candidateName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            match.jobTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _Score(match.matchPercentage),
                  ],
                ),
              );
            }).toList(),
          ),
  );
}

class _VacancyMetrics extends StatelessWidget {
  const _VacancyMetrics({required this.vacancies});
  final List<VacancyMetric> vacancies;

  @override
  Widget build(BuildContext context) => _Panel(
    title: 'Active Job Vacancies',
    subtitle: 'Applicant volume and AI screening coverage',
    child: vacancies.isEmpty
        ? const _Empty('No active vacancies created yet.')
        : Column(
            children: vacancies.asMap().entries.map((entry) {
              final vacancy = entry.value;
              return _ListDivider(
                last: entry.key == vacancies.length - 1,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vacancy.title,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            vacancy.department,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _Count(label: 'Applicants', value: vacancy.applicantsCount),
                    const SizedBox(width: 15),
                    _Count(
                      label: 'AI screened',
                      value: vacancy.aiScreenedCount,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
  );
}

class _PipelineHealth extends StatelessWidget {
  const _PipelineHealth({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final stages = <(String, int)>[
      ('Applied', stats.totalCandidatesCount),
      ('AI Screened', stats.aiScreenedCount),
      ('Shortlisted', stats.shortlistedCount),
      ('Pipeline', stats.pendingInterviewsCount),
    ];
    final maximum = stages.fold<int>(
      1,
      (max, stage) => stage.$2 > max ? stage.$2 : max,
    );
    final conversion = stats.totalCandidatesCount == 0
        ? 0
        : (stats.shortlistedCount * 100 / stats.totalCandidatesCount).round();
    return _Panel(
      title: 'Hiring Pipeline Health',
      subtitle: 'Overall funnel conversion',
      child: Column(
        children: [
          ...stages.map(
            (stage) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        stage.$1,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${stage.$2}',
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: stage.$2 / maximum,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              children: [
                Text(
                  '$conversion%',
                  style: const TextStyle(
                    color: Color(0xFF047857),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Applied-to-shortlist conversion',
                    style: TextStyle(
                      color: Color(0xFF047857),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentActivity extends StatelessWidget {
  const _RecentActivity({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final activity = stats.recentAiActivity;
    return _Panel(
      title: 'Recent AI Activity',
      subtitle: 'Signals requiring attention',
      child: Column(
        children: [
          _Alert(
            icon: Icons.auto_awesome_rounded,
            color: const Color(0xFF059669),
            background: const Color(0xFFECFDF5),
            title: activity == null
                ? 'No AI activity yet'
                : 'AI screening completed',
            message: activity == null
                ? 'Run a candidate screen to generate live matching insights.'
                : '${activity.jobTitle} produced a ${activity.matchPercentage}% candidate match.',
          ),
          const SizedBox(height: 10),
          _Alert(
            icon: Icons.priority_high_rounded,
            color: const Color(0xFFD97706),
            background: const Color(0xFFFFFBEB),
            title: 'Evaluation queue',
            message:
                '${stats.pendingAiEvaluationsCount} pending applications require AI evaluation.',
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        Padding(padding: const EdgeInsets.all(16), child: child),
      ],
    ),
  );
}

class _ListDivider extends StatelessWidget {
  const _ListDivider({required this.child, required this.last});
  final Widget child;
  final bool last;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 11),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
    ),
    child: child,
  );
}

class _Count extends StatelessWidget {
  const _Count({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        '$value',
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      Text(
        label,
        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9),
      ),
    ],
  );
}

class _Score extends StatelessWidget {
  const _Score(this.score);
  final int score;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF059669),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      '$score%',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: const Color(0xFFECFDF5),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF047857),
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _Alert extends StatelessWidget {
  const _Alert({
    required this.icon,
    required this.color,
    required this.background,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final Color color;
  final Color background;
  final String title;
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 12,
        height: 1.4,
      ),
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 44,
            color: Color(0xFFDC2626),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 18),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      border: Border.all(color: const Color(0xFFFECACA)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'Could not refresh dashboard data.',
            style: TextStyle(color: Color(0xFFB91C1C), fontSize: 12),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
