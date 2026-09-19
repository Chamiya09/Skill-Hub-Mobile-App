import 'package:flutter/material.dart';

import '../../models/job_vacancy.dart';
import '../../widgets/hr_mobile_ui.dart';
import '../../models/pipeline_candidate.dart';
import '../../services/ai_pipeline_service.dart';
import '../../services/jobs_service.dart';

enum _PipelineView { screening, shortlist }

class ScreeningPipelinePage extends StatefulWidget {
  const ScreeningPipelinePage({
    super.key,
    this.jobsService,
    this.pipelineService,
  });
  final JobsService? jobsService;
  final AiPipelineService? pipelineService;
  @override
  State<ScreeningPipelinePage> createState() => _ScreeningPipelinePageState();
}

class _ScreeningPipelinePageState extends State<ScreeningPipelinePage> {
  late final _jobsService = widget.jobsService ?? JobsService();
  late final _pipelineService = widget.pipelineService ?? AiPipelineService();
  final _search = TextEditingController();
  List<JobVacancy> _jobs = const [];
  List<PipelineCandidate> _candidates = const [];
  final Set<String> _selected = {};
  JobVacancy? _job;
  _PipelineView _view = _PipelineView.screening;
  bool _loading = true;
  bool _working = false;
  String? _error;
  String _quickFilter = 'All';
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _search.addListener(_refreshSearch);
    _loadJobs();
  }

  @override
  void dispose() {
    _search.removeListener(_refreshSearch);
    _search.dispose();
    super.dispose();
  }

  void _refreshSearch() => setState(() {});

  Future<void> _loadJobs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final jobs = await _jobsService.getJobs();
      final published = jobs
          .where((job) => job.status.toLowerCase() != 'draft')
          .toList();
      if (!mounted) return;
      setState(() {
        _jobs = published;
        _job = published.isEmpty
            ? null
            : published.firstWhere(
                (job) => job.id == _job?.id,
                orElse: () => published.first,
              );
      });
      await _loadCandidates();
    } on JobsException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadCandidates() async {
    final job = _job;
    if (job == null) {
      if (mounted) setState(() => _candidates = const []);
      return;
    }
    final request = ++_request;
    final view = _view;
    setState(() {
      _loading = true;
      _error = null;
      _selected.clear();
      _candidates = const [];
    });
    try {
      final candidates = view == _PipelineView.screening
          ? await _pipelineService.getRankedApplicants(job.id)
          : await _pipelineService.getShortlisted(job.id);
      if (mounted && request == _request) {
        setState(() => _candidates = candidates);
      }
    } on AiPipelineException catch (error) {
      if (mounted && request == _request) {
        setState(() => _error = error.message);
      }
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  Future<void> _changeJob(JobVacancy job) async {
    setState(() => _job = job);
    await _loadCandidates();
  }

  Future<void> _changeView(_PipelineView view) async {
    if (_view == view) return;
    setState(() => _view = view);
    await _loadCandidates();
  }

  Future<void> _runScreening() async {
    final job = _job;
    if (job == null) return;
    setState(() {
      _working = true;
      _error = null;
    });
    try {
      final candidates = await _pipelineService.runScreening(job.id);
      if (!mounted) return;
      setState(() => _candidates = candidates);
      _showMessage('AI screening completed and candidates were re-ranked.');
    } on AiPipelineException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _confirmShortlist() async {
    final selected = _candidates
        .where((candidate) => _selected.contains(candidate.candidateId))
        .toList();
    if (selected.isEmpty) return;
    final confirmed = await showHrSheet<bool>(
      context,
      builder: (context) => HrSheet(
        title: 'Review shortlist',
        subtitle: '${selected.length} candidates will advance in the pipeline.',
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: selected
              .map(
                (candidate) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: HrCard(
                    child: HrDetail(candidate.name, candidate.headline),
                  ),
                ),
              )
              .toList(),
        ),
        footer: HrSaveButton(
          label: 'Confirm shortlist',
          onPressed: () => Navigator.pop(context, true),
        ),
      ),
    );
    if (confirmed == true && mounted) await _shortlistSelected();
  }

  Future<void> _shortlistSelected() async {
    final job = _job;
    if (job == null || _selected.isEmpty) return;
    setState(() => _working = true);
    try {
      await _pipelineService.moveToShortlist(job.id, _selected);
      if (!mounted) return;
      final count = _selected.length;
      _selected.clear();
      await _loadCandidates();
      if (!mounted) return;
      _showMessage(
        '$count candidate${count == 1 ? '' : 's'} moved to shortlist.',
      );
    } on AiPipelineException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _chooseCandidates() async {
    final eligible = _candidates
        .where((candidate) => candidate.status.toLowerCase() == 'applied')
        .toList();
    final selection = await showHrSheet<Set<String>>(
      context,
      builder: (_) =>
          _CandidateSelection(candidates: eligible, selected: _selected),
    );
    if (selection != null && mounted) {
      setState(() {
        _selected
          ..clear()
          ..addAll(selection);
      });
    }
  }

  void _viewCandidate(PipelineCandidate candidate) {
    showHrSheet<void>(
      context,
      builder: (context) => HrSheet(
        title: 'Candidate Details',
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            HrCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HrDetail('Full name', candidate.name),
                  HrDetail('Headline', candidate.headline),
                  HrDetail('Email', candidate.email),
                  HrDetail('Location', candidate.location),
                  HrDetail('Application status', candidate.status),
                  HrDetail(
                    'AI match score',
                    candidate.aiScore == null
                        ? 'Not scored yet'
                        : '${candidate.aiScore}%',
                  ),
                  HrDetail(
                    'Applied / shortlisted',
                    candidate.appliedAt
                            ?.toLocal()
                            .toString()
                            .split('.')
                            .first ??
                        'Not available',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            HrCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skills',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  if (candidate.skills.isEmpty)
                    const Text('No skills provided'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: candidate.skills
                        .map((skill) => Chip(label: Text(skill)))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
        footer: HrSaveButton(
          label: 'Done',
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final visible = _candidates
        .where(
          (candidate) =>
              (query.isEmpty ||
                  candidate.name.toLowerCase().contains(query) ||
                  candidate.headline.toLowerCase().contains(query) ||
                  candidate.location.toLowerCase().contains(query) ||
                  candidate.skills.any(
                    (skill) => skill.toLowerCase().contains(query),
                  )) &&
              (_quickFilter != '80%+ match' ||
                  (candidate.aiScore ?? 0) >= 80) &&
              (_quickFilter != 'Selected' ||
                  _selected.contains(candidate.candidateId)),
        )
        .toList();
    final screened = _candidates
        .where((candidate) => candidate.aiScore != null)
        .length;
    final highMatches = _candidates
        .where((candidate) => (candidate.aiScore ?? 0) >= 80)
        .length;

    return RefreshIndicator(
      color: const Color(0xFF10B981),
      onRefresh: () async {
        if (!_working) await _loadJobs();
      },
      child: ListView(
        key: const PageStorageKey('screening-pipeline-page'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          const _PipelineHeader(),
          const SizedBox(height: 14),
          _JobSelector(
            jobs: _jobs,
            selected: _job,
            onChanged: _working || _loading ? null : _changeJob,
          ),
          const SizedBox(height: 14),
          _ViewTabs(
            view: _view,
            onChanged: _working || _loading ? null : _changeView,
          ),
          const SizedBox(height: 14),
          _MetricsRow(
            applicants: _candidates.length,
            screened: screened,
            highMatches: highMatches,
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            _ErrorCard(
              message: _error!,
              onRetry: _job == null ? _loadJobs : _loadCandidates,
            ),
          ],
          const SizedBox(height: 14),
          _ActionPanel(
            view: _view,
            job: _job,
            selectedCount: _selected.length,
            working: _working || _loading,
            onChoose: _chooseCandidates,
            onRunScreening: _runScreening,
            onShortlist: _confirmShortlist,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: _view == _PipelineView.screening
                  ? 'Search ranked candidates or skills'
                  : 'Search shortlisted talent',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      onPressed: _search.clear,
                      icon: const Icon(Icons.close_rounded),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...['All', '80%+ match', 'Selected'].map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: _quickFilter == filter,
                      onSelected: (_) => setState(() => _quickFilter = filter),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionTitle(
            title: _view == _PipelineView.screening
                ? 'Candidate ranking'
                : 'Hiring shortlist',
            count: visible.length,
          ),
          const SizedBox(height: 10),
          if (_loading)
            const _LoadingCard()
          else if (_job == null)
            const _EmptyCard(
              icon: Icons.work_outline_rounded,
              title: 'No published vacancies',
              message: 'Publish a job vacancy before starting AI screening.',
            )
          else if (visible.isEmpty)
            _EmptyCard(
              icon: _view == _PipelineView.screening
                  ? Icons.auto_awesome_outlined
                  : Icons.people_outline_rounded,
              title: query.isNotEmpty || _quickFilter != 'All'
                  ? 'No matching candidates'
                  : _view == _PipelineView.screening
                  ? 'No applicants to screen'
                  : 'No shortlisted candidates',
              message: query.isNotEmpty || _quickFilter != 'All'
                  ? 'Try another filter, name, location, or skill.'
                  : _view == _PipelineView.screening
                  ? 'Applications for this vacancy will appear here.'
                  : 'Select candidates from AI Screening to build this shortlist.',
            )
          else
            ...visible.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _CandidateCard(
                  key: ValueKey(entry.value.candidateId),
                  candidate: entry.value,
                  rank: _candidates.indexOf(entry.value) + 1,
                  selected: _selected.contains(entry.value.candidateId),
                  onView: () => _viewCandidate(entry.value),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PipelineHeader extends StatelessWidget {
  const _PipelineHeader();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Colors.white, Color(0xFFECFDF5)]),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBox(icon: Icons.auto_awesome_rounded, filled: true),
        SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Hiring Pipeline',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Rank applicants with AI and advance the strongest candidates into your hiring shortlist.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _JobSelector extends StatelessWidget {
  const _JobSelector({
    required this.jobs,
    required this.selected,
    required this.onChanged,
  });
  final List<JobVacancy> jobs;
  final JobVacancy? selected;
  final ValueChanged<JobVacancy>? onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    key: ValueKey(selected?.id),
    initialValue: selected?.id,
    isExpanded: true,
    decoration: const InputDecoration(
      labelText: 'Job requisition',
      prefixIcon: Icon(Icons.work_outline_rounded),
    ),
    hint: const Text('No published vacancies'),
    items: jobs
        .map(
          (job) => DropdownMenuItem(
            value: job.id,
            child: Text(job.title, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
    onChanged: onChanged == null
        ? null
        : (id) {
            if (id != null) onChanged!(jobs.firstWhere((job) => job.id == id));
          },
  );
}

class _ViewTabs extends StatelessWidget {
  const _ViewTabs({required this.view, required this.onChanged});
  final _PipelineView view;
  final ValueChanged<_PipelineView>? onChanged;
  @override
  Widget build(BuildContext context) => SegmentedButton<_PipelineView>(
    segments: const [
      ButtonSegment(
        value: _PipelineView.screening,
        icon: Icon(Icons.auto_awesome_outlined),
        label: Text('AI Screening'),
      ),
      ButtonSegment(
        value: _PipelineView.shortlist,
        icon: Icon(Icons.star_outline_rounded),
        label: Text('Shortlist'),
      ),
    ],
    selected: {view},
    showSelectedIcon: false,
    onSelectionChanged: onChanged == null
        ? null
        : (selection) => onChanged!(selection.first),
  );
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.applicants,
    required this.screened,
    required this.highMatches,
  });
  final int applicants, screened, highMatches;
  @override
  Widget build(BuildContext context) => HrResponsiveTiles(
    children: [
      _Metric(value: applicants, label: 'Candidates'),
      _Metric(value: screened, label: 'AI scored'),
      _Metric(value: highMatches, label: '80%+ match'),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final int value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            color: Color(0xFF059669),
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.view,
    required this.job,
    required this.selectedCount,
    required this.working,
    required this.onRunScreening,
    required this.onShortlist,
    required this.onChoose,
  });
  final _PipelineView view;
  final JobVacancy? job;
  final int selectedCount;
  final bool working;
  final VoidCallback onRunScreening, onShortlist, onChoose;

  @override
  Widget build(BuildContext context) {
    final closed = job?.status.toLowerCase() == 'closed';
    final screening = view == _PipelineView.screening;
    return HrCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                screening ? Icons.auto_awesome_rounded : Icons.route_rounded,
                color: hrEmerald,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  screening
                      ? closed
                            ? 'Ready for AI ranking'
                            : 'Applications are open'
                      : 'Hiring shortlist',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            screening
                ? closed
                      ? 'Review ranked profiles and choose candidates to advance.'
                      : 'Review applicants. Close this vacancy in Jobs before refreshing AI scores.'
                : 'Candidates advanced from AI screening appear here.',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (screening) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: working || job == null ? null : onChoose,
                  icon: const Icon(Icons.people_outline_rounded),
                  label: Text(
                    selectedCount == 0
                        ? 'Select candidates'
                        : '$selectedCount selected',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: working || !closed ? null : onRunScreening,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Run AI screening'),
                ),
              ],
            ),
            if (selectedCount > 0) ...[
              const SizedBox(height: 12),
              HrSaveButton(
                label: 'Move $selectedCount to shortlist',
                busy: working,
                onPressed: onShortlist,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    super.key,
    required this.candidate,
    required this.rank,
    required this.selected,
    required this.onView,
  });
  final PipelineCandidate candidate;
  final int rank;
  final bool selected;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final initials = candidate.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return HrCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFD1FAE5),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Color(0xFF047857),
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
                      candidate.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      candidate.headline,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '#$rank',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (candidate.aiScore != null)
                _ScoreBadge(score: candidate.aiScore!)
              else
                const Text('Not scored yet'),
              Chip(label: Text(candidate.status)),
              if (selected)
                const Chip(
                  avatar: Icon(
                    Icons.check_circle_rounded,
                    color: hrEmerald,
                    size: 18,
                  ),
                  label: Text('Selected'),
                ),
            ],
          ),
          HrDetail('Location', candidate.location),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: candidate.skills
                .take(4)
                .map((skill) => Chip(label: Text(skill)))
                .toList(),
          ),
          ExpansionTile(
            key: PageStorageKey('candidate-details-${candidate.candidateId}'),
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 12),
            title: const Text(
              'Contact & additional details',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HrDetail('Email', candidate.email),
                    HrDetail(
                      'Applied / shortlisted',
                      candidate.appliedAt
                              ?.toLocal()
                              .toString()
                              .split('.')
                              .first ??
                          'Not available',
                    ),
                    if (candidate.skills.length > 4)
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: candidate.skills
                            .skip(4)
                            .map((skill) => Chip(label: Text(skill)))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onView,
              icon: const Icon(Icons.person_outline_rounded),
              label: const Text('View Details'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CandidateSelection extends StatefulWidget {
  const _CandidateSelection({required this.candidates, required this.selected});
  final List<PipelineCandidate> candidates;
  final Set<String> selected;
  @override
  State<_CandidateSelection> createState() => _CandidateSelectionState();
}

class _CandidateSelectionState extends State<_CandidateSelection> {
  late final Set<String> _draft = {...widget.selected};
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final visible = widget.candidates
        .where(
          (candidate) =>
              candidate.name.toLowerCase().contains(_query) ||
              candidate.skills.any(
                (skill) => skill.toLowerCase().contains(_query),
              ),
        )
        .toList();
    return HrSheet(
      title: 'Select candidates',
      subtitle: '${_draft.length} selected for shortlisting',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            onChanged: (value) =>
                setState(() => _query = value.trim().toLowerCase()),
            decoration: const InputDecoration(
              labelText: 'Find candidates',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(_draft.clear),
            child: const Text('Clear selection'),
          ),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('No eligible candidates match this search.'),
            ),
          ...visible.map(
            (candidate) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: HrCard(
                padding: EdgeInsets.zero,
                child: CheckboxListTile(
                  activeColor: hrEmerald,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    candidate.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${candidate.headline}\nAI match: ${candidate.aiScore == null ? 'Not scored' : '${candidate.aiScore}%'}',
                  ),
                  value: _draft.contains(candidate.candidateId),
                  onChanged: (checked) => setState(() {
                    checked == true
                        ? _draft.add(candidate.candidateId)
                        : _draft.remove(candidate.candidateId);
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
      footer: HrSaveButton(
        label: 'Apply Selection',
        onPressed: () => Navigator.pop(context, _draft),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.score});
  final int score;
  @override
  Widget build(BuildContext context) {
    final strong = score >= 80;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: strong ? const Color(0xFFD1FAE5) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$score%',
        style: TextStyle(
          color: strong ? const Color(0xFF047857) : const Color(0xFF2563EB),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});
  final String title;
  final int count;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      Text(
        '$count candidates',
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 11),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 50),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: const Center(
      child: CircularProgressIndicator(color: Color(0xFF10B981)),
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title, message;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      children: [
        _IconBox(icon: icon),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 11,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, this.filled = false});
  final IconData icon;
  final bool filled;
  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: filled ? const Color(0xFF10B981) : const Color(0xFFD1FAE5),
      borderRadius: BorderRadius.circular(13),
    ),
    child: Icon(
      icon,
      color: filled ? Colors.white : const Color(0xFF059669),
      size: 24,
    ),
  );
}
