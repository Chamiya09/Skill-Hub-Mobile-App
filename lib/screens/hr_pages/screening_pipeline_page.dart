import 'package:flutter/material.dart';

import '../../models/job_vacancy.dart';
import '../../models/pipeline_candidate.dart';
import '../../services/ai_pipeline_service.dart';
import '../../services/jobs_service.dart';

enum _PipelineView { screening, shortlist }

class ScreeningPipelinePage extends StatefulWidget {
  const ScreeningPipelinePage({super.key});
  @override
  State<ScreeningPipelinePage> createState() => _ScreeningPipelinePageState();
}

class _ScreeningPipelinePageState extends State<ScreeningPipelinePage> {
  final _jobsService = JobsService();
  final _pipelineService = AiPipelineService();
  final _search = TextEditingController();
  List<JobVacancy> _jobs = const [];
  List<PipelineCandidate> _candidates = const [];
  final Set<String> _selected = {};
  JobVacancy? _job;
  _PipelineView _view = _PipelineView.screening;
  bool _loading = true;
  bool _working = false;
  String? _error;

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
        _job = published.isEmpty ? null : published.first;
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
    setState(() {
      _loading = true;
      _error = null;
      _selected.clear();
    });
    try {
      final candidates = _view == _PipelineView.screening
          ? await _pipelineService.getRankedApplicants(job.id)
          : await _pipelineService.getShortlisted(job.id);
      if (mounted) setState(() => _candidates = candidates);
    } on AiPipelineException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
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
      _showMessage(
        '$count candidate${count == 1 ? '' : 's'} moved to shortlist.',
      );
    } on AiPipelineException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _working = false);
    }
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
              query.isEmpty ||
              candidate.name.toLowerCase().contains(query) ||
              candidate.headline.toLowerCase().contains(query) ||
              candidate.location.toLowerCase().contains(query) ||
              candidate.skills.any(
                (skill) => skill.toLowerCase().contains(query),
              ),
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
      onRefresh: _loadCandidates,
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
            onChanged: _working ? null : _changeJob,
          ),
          const SizedBox(height: 14),
          _ViewTabs(view: _view, onChanged: _working ? null : _changeView),
          const SizedBox(height: 14),
          _MetricsRow(
            applicants: _candidates.length,
            screened: screened,
            highMatches: highMatches,
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            _ErrorCard(message: _error!, onRetry: _loadCandidates),
          ],
          const SizedBox(height: 14),
          _ActionPanel(
            view: _view,
            job: _job,
            selectedCount: _selected.length,
            working: _working,
            onRunScreening: _runScreening,
            onShortlist: _shortlistSelected,
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
              title: query.isNotEmpty
                  ? 'No matching candidates'
                  : _view == _PipelineView.screening
                  ? 'No applicants to screen'
                  : 'No shortlisted candidates',
              message: query.isNotEmpty
                  ? 'Try a different name, location, or skill.'
                  : _view == _PipelineView.screening
                  ? 'Applications for this vacancy will appear here.'
                  : 'Select candidates from AI Screening to build this shortlist.',
            )
          else
            ...visible.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _CandidateCard(
                  candidate: entry.value,
                  rank: entry.key + 1,
                  selectable:
                      _view == _PipelineView.screening &&
                      entry.value.status.toLowerCase() != 'shortlisted',
                  selected: _selected.contains(entry.value.candidateId),
                  onSelected: (selected) => setState(() {
                    selected
                        ? _selected.add(entry.value.candidateId)
                        : _selected.remove(entry.value.candidateId);
                  }),
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
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _Metric(value: applicants, label: 'Candidates'),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _Metric(value: screened, label: 'AI scored'),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: _Metric(value: highMatches, label: '80%+ match'),
      ),
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
          maxLines: 1,
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
  });
  final _PipelineView view;
  final JobVacancy? job;
  final int selectedCount;
  final bool working;
  final VoidCallback onRunScreening, onShortlist;
  @override
  Widget build(BuildContext context) {
    final closed = job?.status.toLowerCase() == 'closed';
    final screening = view == _PipelineView.screening;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: screening ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: screening ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            screening ? Icons.bolt_rounded : Icons.route_rounded,
            color: const Color(0xFF059669),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              screening
                  ? closed
                        ? 'Vacancy closed and ready for AI ranking.'
                        : 'Review applicants. Close the vacancy before refreshing AI scores.'
                  : 'Candidates advanced from AI screening appear here.',
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
          if (screening && selectedCount > 0)
            FilledButton(
              onPressed: working ? null : onShortlist,
              child: Text('Shortlist $selectedCount'),
            )
          else if (screening)
            IconButton.filled(
              tooltip: closed
                  ? 'Run AI screening'
                  : 'Close vacancy to refresh screening',
              onPressed: working || !closed ? null : onRunScreening,
              icon: working
                  ? const SizedBox.square(
                      dimension: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
            ),
        ],
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.rank,
    required this.selectable,
    required this.selected,
    required this.onSelected,
  });
  final PipelineCandidate candidate;
  final int rank;
  final bool selectable, selected;
  final ValueChanged<bool> onSelected;
  @override
  Widget build(BuildContext context) {
    final initials = candidate.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: selectable ? () => onSelected(!selected) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE2E8F0),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: const Color(0xFFD1FAE5),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF047857),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                candidate.name,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (candidate.aiScore != null)
                              _ScoreBadge(score: candidate.aiScore!),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          candidate.headline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                candidate.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (selectable) ...[
                    const SizedBox(width: 6),
                    Checkbox(
                      value: selected,
                      onChanged: (value) => onSelected(value ?? false),
                    ),
                  ] else
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Shortlisted',
                        style: TextStyle(
                          color: Color(0xFF047857),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              if (candidate.skills.isNotEmpty) ...[
                const Divider(height: 22, color: Color(0xFFF1F5F9)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: candidate.skills
                        .take(4)
                        .map(
                          (skill) => Chip(
                            label: Text(skill),
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '#$rank',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    candidate.status,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
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
