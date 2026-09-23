import 'package:flutter/material.dart';

import '../../components/company_logo_button.dart';
import '../../models/job.dart';
import '../../services/public_jobs_service.dart';
import 'find_jobs_screen.dart';
import 'job_view_screen.dart';

const _emerald = Color(0xFF10B981);
const _emeraldDark = Color(0xFF047857);
const _ink = Color(0xFF111827);
const _bodyText = Color(0xFF64748B);
const _border = Color(0xFFE5E7EB);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PublicJobsService _jobsService = PublicJobsService();
  final Set<String> _savedJobIds = <String>{};
  List<Job> _jobs = const [];
  bool _isLoading = true;
  bool _showAll = false;
  int _requestGeneration = 0;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _jobsService.dispose();
    super.dispose();
  }

  Future<void> _loadJobs({String? search, bool? showAll}) async {
    final requestGeneration = ++_requestGeneration;
    final nextSearch = search ?? _searchQuery;
    final nextShowAll = showAll ?? _showAll;
    setState(() {
      _isLoading = true;
      _error = null;
      _searchQuery = nextSearch;
      _showAll = nextShowAll;
    });

    try {
      final jobs = await _jobsService.getJobs(
        search: nextSearch,
        limit: nextShowAll ? null : 6,
      );
      if (!mounted || requestGeneration != _requestGeneration) return;
      setState(() => _jobs = jobs);
    } on JobsApiException catch (error) {
      if (!mounted || requestGeneration != _requestGeneration) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted && requestGeneration == _requestGeneration) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: RefreshIndicator(
        color: _emerald,
        onRefresh: _loadJobs,
        child: CustomScrollView(
          key: const PageStorageKey('candidate-home-scroll'),
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              sliver: SliverList.list(
                children: [
                  const SizedBox(height: 8),
                  const _HeroBadge(),
                  const SizedBox(height: 18),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        color: _ink,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -1,
                      ),
                      children: [
                        TextSpan(text: 'Find your next role with '),
                        TextSpan(
                          text: 'AI precision',
                          style: TextStyle(color: _emeraldDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Discover verified technical roles from registered employers, matched to your skills.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _bodyText,
                      fontSize: 14,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SearchField(
                    onSearch: (query) => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => FindJobsScreen(initialQuery: query),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _TrustHighlights(
                    activeJobs: _jobs.length,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 32),
                  const _FeatureStrip(),
                  const SizedBox(height: 34),
                  _SectionHeader(
                    title: _searchQuery.isEmpty
                        ? 'Top live opportunities'
                        : 'Results for “$_searchQuery”',
                    subtitle: _searchQuery.isEmpty
                        ? 'FEATURED ROLES'
                        : '${_jobs.length} MATCHING ${_jobs.length == 1 ? 'ROLE' : 'ROLES'}',
                    actionLabel: _showAll || _searchQuery.isNotEmpty
                        ? null
                        : 'View all',
                    onAction: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const FindJobsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_isLoading) const _JobsLoadingState(),
                  if (!_isLoading && _error != null)
                    _JobsErrorState(message: _error!, onRetry: _loadJobs),
                  if (!_isLoading && _error == null && _jobs.isEmpty)
                    _JobsEmptyState(hasSearch: _searchQuery.isNotEmpty),
                  if (!_isLoading && _error == null)
                    ..._jobs.map(
                      (job) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _JobCard(
                          job: job,
                          isSaved: _savedJobIds.contains(job.id),
                          onSave: () {
                            setState(() {
                              if (!_savedJobIds.add(job.id)) {
                                _savedJobIds.remove(job.id);
                              }
                            });
                          },
                          onView: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => JobViewScreen(initialJob: job),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          border: Border.all(color: const Color(0xFFA7F3D0)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: _emeraldDark, size: 14),
            SizedBox(width: 6),
            Text(
              'AI-POWERED RECRUITMENT',
              style: TextStyle(
                color: _emeraldDark,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.onSearch});

  final ValueChanged<String> onSearch;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final hasText = value.isNotEmpty;
    if (hasText != _hasText) setState(() => _hasText = hasText);
  }

  void _submit([String? value]) {
    widget.onSearch((value ?? _controller.text).trim());
  }

  void _clear() {
    _controller.clear();
    setState(() => _hasText = false);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 4, 5, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFDCE5E1)),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 20,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: _submit,
              style: const TextStyle(color: _ink, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Jobs, companies, or skills...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_hasText)
            IconButton(
              tooltip: 'Clear search',
              onPressed: _clear,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.close_rounded,
                color: Color(0xFF94A3B8),
                size: 19,
              ),
            ),
          SizedBox(
            width: 48,
            height: 46,
            child: IconButton.filled(
              tooltip: 'Search jobs',
              onPressed: _submit,
              style: IconButton.styleFrom(
                backgroundColor: _emerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 21),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustHighlights extends StatelessWidget {
  const _TrustHighlights({required this.activeJobs, required this.isLoading});

  final int activeJobs;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 8,
      children: [
        _TrustItem(
          label: isLoading ? 'Loading roles...' : '$activeJobs active roles',
        ),
        const _TrustItem(label: 'AI matching'),
        const _TrustItem(label: 'Direct employers'),
      ],
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, color: _emerald, size: 15),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: _bodyText,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FeatureStrip extends StatelessWidget {
  const _FeatureStrip();

  static const _features = [
    (
      Icons.track_changes_rounded,
      'AI Match Scoring',
      'Roles ranked against your skills.',
    ),
    (
      Icons.bolt_rounded,
      'Instant Applications',
      'Apply directly without middlemen.',
    ),
    (
      Icons.trending_up_rounded,
      'Real-time Tracking',
      'Follow every application update.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _features.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final feature = _features[index];
          return Container(
            width: 205,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 16,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(feature.$1, color: _emeraldDark, size: 21),
                ),
                const SizedBox(height: 12),
                Text(
                  feature.$2,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  feature.$3,
                  style: const TextStyle(
                    color: _bodyText,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: _emeraldDark,
                      size: 12,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _emeraldDark,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 9),
              Text(
                title,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: _emeraldDark,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.isSaved,
    required this.onSave,
    required this.onView,
  });

  final Job job;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyLogoButton(
                companyIdentifier: job.companyId.isNotEmpty
                    ? job.companyId
                    : job.companyName,
                initials: job.companyInitials,
                logoUrl: job.logoUrl,
                size: 46,
                backgroundColor: const Color(0xFFF0FDF4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.companyName,
                      style: const TextStyle(
                        color: _bodyText,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: isSaved ? 'Remove saved job' : 'Save job',
                onPressed: onSave,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved ? _emerald : _bodyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaPill(icon: Icons.location_on_outlined, label: job.location),
              _MetaPill(
                icon: Icons.business_center_outlined,
                label: job.employmentType,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: job.detailTags
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.salaryLabel,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.postedLabel,
                      style: const TextStyle(color: _bodyText, fontSize: 11),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: onView,
                style: FilledButton.styleFrom(
                  backgroundColor: _emerald,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
                child: const Text(
                  'View',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JobsLoadingState extends StatelessWidget {
  const _JobsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Container(
          height: 218,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: _emerald, strokeWidth: 2.5),
          ),
        ),
      ),
    );
  }
}

class _JobsErrorState extends StatelessWidget {
  const _JobsErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _JobsMessageCard(
      icon: Icons.cloud_off_outlined,
      title: 'Could not load jobs',
      message: message,
      actionLabel: 'Try again',
      onAction: onRetry,
    );
  }
}

class _JobsEmptyState extends StatelessWidget {
  const _JobsEmptyState({required this.hasSearch});

  final bool hasSearch;

  @override
  Widget build(BuildContext context) {
    return _JobsMessageCard(
      icon: Icons.search_off_rounded,
      title: hasSearch ? 'No matching jobs' : 'No active vacancies right now',
      message: hasSearch
          ? 'Try a different role, company, skill, or location.'
          : 'Employers are updating their open roles. Please check back soon.',
    );
  }
}

class _JobsMessageCard extends StatelessWidget {
  const _JobsMessageCard({
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
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _bodyText),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _ink,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _bodyText, fontSize: 12, height: 1.5),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  color: _emeraldDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _bodyText, size: 15),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: _bodyText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
