import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../services/public_jobs_service.dart';
import 'job_view_screen.dart';

const _emerald = Color(0xFF10B981);
const _emeraldDark = Color(0xFF047857);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);

class FindJobsScreen extends StatefulWidget {
  const FindJobsScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends State<FindJobsScreen> {
  final PublicJobsService _service = PublicJobsService();
  late final TextEditingController _searchController;
  final Set<String> _savedIds = {};
  List<Job> _jobs = const [];
  bool _loading = true;
  String? _error;
  String _query = '';
  String _workType = 'All';
  String _experience = 'All';
  String _sort = 'Recent';

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim();
    _searchController = TextEditingController(text: _query);
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final jobs = await _service.getJobs(limit: null);
      if (mounted) setState(() => _jobs = jobs);
    } on JobsApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Job> get _filteredJobs {
    final term = _query.toLowerCase();
    final result = _jobs.where((job) {
      final matchesQuery =
          term.isEmpty ||
          job.title.toLowerCase().contains(term) ||
          job.companyName.toLowerCase().contains(term) ||
          job.department.toLowerCase().contains(term) ||
          job.location.toLowerCase().contains(term) ||
          job.tags.any((tag) => tag.toLowerCase().contains(term));
      final matchesType =
          _workType == 'All' ||
          job.employmentType.toLowerCase().contains(_workType.toLowerCase());
      final matchesExperience =
          _experience == 'All' ||
          job.experienceLevel.toLowerCase().contains(_experience.toLowerCase());
      return matchesQuery && matchesType && matchesExperience;
    }).toList();
    if (_sort == 'Recent') {
      result.sort(
        (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
          a.createdAt ?? DateTime(1970),
        ),
      );
    } else {
      result.sort((a, b) => a.title.compareTo(b.title));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredJobs;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Find Jobs',
          style: TextStyle(
            color: _ink,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: _emerald,
        onRefresh: _loadJobs,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
          children: [
            const _FindJobsHero(),
            const SizedBox(height: 22),
            _FilterCard(
              controller: _searchController,
              workType: _workType,
              experience: _experience,
              sort: _sort,
              onQueryChanged: (value) => setState(() => _query = value.trim()),
              onWorkTypeChanged: (value) => setState(() => _workType = value),
              onExperienceChanged: (value) =>
                  setState(() => _experience = value),
              onSortChanged: (value) => setState(() => _sort = value),
              onReset: _resetFilters,
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available opportunities',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${results.length} verified ${results.length == 1 ? 'role' : 'roles'} found',
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: _emeraldDark,
                        size: 14,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: _emeraldDark,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (_loading) ...List.generate(3, (_) => const _JobSkeleton()),
            if (!_loading && _error != null)
              _MessageCard(
                icon: Icons.cloud_off_outlined,
                title: 'Could not load jobs',
                message: _error!,
                onRetry: _loadJobs,
              ),
            if (!_loading && _error == null && results.isEmpty)
              const _MessageCard(
                icon: Icons.search_off_rounded,
                title: 'No matching jobs',
                message: 'Try changing your keywords or filters.',
              ),
            if (!_loading && _error == null)
              ...results.map(
                (job) => Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: _ResultJobCard(
                    job: job,
                    saved: _savedIds.contains(job.id),
                    onSave: () => setState(
                      () => _savedIds.contains(job.id)
                          ? _savedIds.remove(job.id)
                          : _savedIds.add(job.id),
                    ),
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
    );
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _workType = 'All';
      _experience = 'All';
      _sort = 'Recent';
    });
  }
}

class _FindJobsHero extends StatelessWidget {
  const _FindJobsHero();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          border: Border.all(color: const Color(0xFFA7F3D0)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_rounded, color: _emeraldDark, size: 13),
            SizedBox(width: 5),
            Text(
              'LIVE VACANCY DIRECTORY',
              style: TextStyle(
                color: _emeraldDark,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 13),
      const Text(
        'Discover high-impact roles\nmatched to your skills',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: _ink,
          fontSize: 27,
          height: 1.18,
          fontWeight: FontWeight.w900,
          letterSpacing: -.8,
        ),
      ),
      const SizedBox(height: 10),
      const Text(
        'Browse verified technical positions directly from employer applicant tracking systems.',
        textAlign: TextAlign.center,
        style: TextStyle(color: _muted, fontSize: 12.5, height: 1.5),
      ),
    ],
  );
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.controller,
    required this.workType,
    required this.experience,
    required this.sort,
    required this.onQueryChanged,
    required this.onWorkTypeChanged,
    required this.onExperienceChanged,
    required this.onSortChanged,
    required this.onReset,
  });
  final TextEditingController controller;
  final String workType;
  final String experience;
  final String sort;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onWorkTypeChanged;
  final ValueChanged<String> onExperienceChanged;
  final ValueChanged<String> onSortChanged;
  final VoidCallback onReset;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A0F172A),
          blurRadius: 22,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: Column(
      children: [
        TextField(
          controller: controller,
          onChanged: onQueryChanged,
          decoration: _decoration(
            'Search by title, department, or company...',
            Icons.search_rounded,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Dropdown(
                value: workType,
                icon: Icons.schedule_rounded,
                values: const [
                  'All',
                  'Full-time',
                  'Remote',
                  'Contract',
                  'Part-time',
                ],
                onChanged: onWorkTypeChanged,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _Dropdown(
                value: experience,
                icon: Icons.business_center_outlined,
                values: const ['All', 'Entry', 'Mid', 'Senior', 'Lead'],
                onChanged: onExperienceChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Dropdown(
                value: sort,
                icon: Icons.tune_rounded,
                values: const ['Recent', 'Title A-Z'],
                onChanged: onSortChanged,
              ),
            ),
            const SizedBox(width: 9),
            TextButton(
              onPressed: onReset,
              child: const Text(
                'Reset',
                style: TextStyle(
                  color: _emeraldDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.icon,
    required this.values,
    required this.onChanged,
  });
  final String value;
  final IconData icon;
  final List<String> values;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
    initialValue: value,
    isExpanded: true,
    decoration: _decoration('', icon),
    items: values
        .map(
          (value) => DropdownMenuItem(
            value: value,
            child: Text(value, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );
}

InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
  prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 19),
  filled: true,
  fillColor: const Color(0xFFF8FAFC),
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: _border),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: _border),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: _emerald, width: 1.4),
  ),
);

class _ResultJobCard extends StatelessWidget {
  const _ResultJobCard({
    required this.job,
    required this.saved,
    required this.onSave,
    required this.onView,
  });
  final Job job;
  final bool saved;
  final VoidCallback onSave;
  final VoidCallback onView;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: Colors.white,
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
              width: 47,
              height: 47,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFD1FAE5)),
              ),
              child: Text(
                job.companyInitials,
                style: const TextStyle(
                  color: _emeraldDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.companyName,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onSave,
              icon: Icon(
                saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: saved ? _emerald : _muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            _Meta(Icons.location_on_outlined, job.location),
            _Meta(Icons.schedule_rounded, job.employmentType),
            if (job.experienceLevel.isNotEmpty)
              _Meta(Icons.business_center_outlined, job.experienceLevel),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 13),
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
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    job.postedLabel,
                    style: const TextStyle(color: _muted, fontSize: 10),
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: onView,
              style: FilledButton.styleFrom(
                backgroundColor: _emerald,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
              child: const Text(
                'View role',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: _muted, size: 15),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
    ],
  );
}

class _JobSkeleton extends StatelessWidget {
  const _JobSkeleton();
  @override
  Widget build(BuildContext context) => Container(
    height: 190,
    margin: const EdgeInsets.only(bottom: 13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFF1F5F9)),
    ),
    child: const Center(
      child: CircularProgressIndicator(color: _emerald, strokeWidth: 2.3),
    ),
  );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.onRetry,
  });
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onRetry;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(28),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: _border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Icon(icon, color: _muted, size: 34),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 12),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ],
    ),
  );
}
