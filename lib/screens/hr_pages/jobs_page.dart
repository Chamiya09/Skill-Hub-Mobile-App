import 'package:flutter/material.dart';

import '../../models/job_vacancy.dart';
import '../../services/jobs_service.dart';
import 'job_details_page.dart';
import 'job_form_page.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});
  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final _service = JobsService();
  final _search = TextEditingController();
  List<JobVacancy> _jobs = const [];
  bool _loading = true;
  String? _error;
  String _status = 'All';
  String _department = 'All';

  @override
  void initState() {
    super.initState();
    _search.addListener(_changed);
    _load();
  }

  @override
  void dispose() {
    _search.removeListener(_changed);
    _search.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  Future<void> _openForm([JobVacancy? job]) async {
    final saved = await Navigator.push<JobVacancy>(
      context,
      MaterialPageRoute(builder: (_) => JobFormPage(job: job)),
    );
    if (saved != null) {
      await _load();
    }
  }

  Future<void> _delete(JobVacancy job) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFDC2626),
        ),
        title: const Text('Delete Job Vacancy?'),
        content: Text(
          'Permanently delete “${job.title}”? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await _service.deleteJob(job.id);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('“${job.title}” was deleted.')));
      }
    } on JobsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final jobs = await _service.getJobs();
      if (mounted) setState(() => _jobs = jobs);
    } on JobsException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final jobs = _jobs
        .where(
          (job) =>
              (query.isEmpty ||
                  job.title.toLowerCase().contains(query) ||
                  job.department.toLowerCase().contains(query) ||
                  job.location.toLowerCase().contains(query)) &&
              (_status == 'All' || job.status == _status) &&
              (_department == 'All' || job.department == _department),
        )
        .toList();
    final departments = [
      'All',
      ...(_jobs.map((j) => j.department).toSet().toList()..sort()),
    ];
    final active = _jobs
        .where((job) => job.status.toLowerCase() == 'active')
        .length;
    final hasFilters =
        query.isNotEmpty || _status != 'All' || _department != 'All';

    void clearFilters() {
      _search.clear();
      setState(() {
        _status = 'All';
        _department = 'All';
      });
    }

    return RefreshIndicator(
      color: const Color(0xFF10B981),
      onRefresh: _load,
      child: ListView(
        key: const PageStorageKey('jobs-page'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _PageHeader(active: active, onCreate: _openForm),
          const SizedBox(height: 14),
          _FiltersPanel(
            search: _search,
            query: query,
            status: _status,
            department: departments.contains(_department) ? _department : 'All',
            departments: departments,
            hasFilters: hasFilters,
            onStatusChanged: (value) => setState(() => _status = value),
            onDepartmentChanged: (value) => setState(() => _department = value),
            onClear: clearFilters,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFFB91C1C)),
                      ),
                    ),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          _ResultsHeader(
            shown: jobs.length,
            total: _jobs.length,
            filtered: hasFilters,
          ),
          const SizedBox(height: 10),
          if (_loading)
            const _LoadingState()
          else if (jobs.isEmpty)
            _EmptyState(
              filtered: hasFilters,
              onClear: clearFilters,
              onCreate: _openForm,
            )
          else
            ...jobs.map(
              (job) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _JobCard(
                  job: job,
                  onEdit: () => _openForm(job),
                  onDelete: () => _delete(job),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => JobDetailsPage(job: job),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.active, required this.onCreate});

  final int active;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Colors.white, Color(0xFFECFDF5)]),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 320;
            final title = const Text(
              'Job Vacancies',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            );
            final button = FilledButton.icon(
              onPressed: onCreate,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('New'),
            );
            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [title, const SizedBox(height: 12), button],
              );
            }
            return Row(
              children: [
                Expanded(child: title),
                const SizedBox(width: 10),
                button,
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage company requisitions and candidate pipelines.',
          style: TextStyle(color: Color(0xFF64748B), height: 1.4),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$active active ${active == 1 ? 'role' : 'roles'}',
            style: const TextStyle(
              color: Color(0xFF047857),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({
    required this.search,
    required this.query,
    required this.status,
    required this.department,
    required this.departments,
    required this.hasFilters,
    required this.onStatusChanged,
    required this.onDepartmentChanged,
    required this.onClear,
  });

  final TextEditingController search;
  final String query;
  final String status;
  final String department;
  final List<String> departments;
  final bool hasFilters;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onDepartmentChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: search,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search title, department, or location',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: query.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    onPressed: search.clear,
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          'STATUS',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: .7,
          ),
        ),
        const SizedBox(height: 7),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ['All', 'Active', 'Draft', 'Closed']
              .map(
                (value) => ChoiceChip(
                  label: Text(value),
                  selected: status == value,
                  selectedColor: const Color(0xFFD1FAE5),
                  onSelected: (_) => onStatusChanged(value),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          key: ValueKey(department),
          initialValue: department,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Department',
            prefixIcon: Icon(Icons.business_outlined),
          ),
          items: departments
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(
                    value == 'All' ? 'All Departments' : value,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              )
              .toList(),
          onChanged: (value) => onDepartmentChanged(value ?? 'All'),
        ),
        if (hasFilters) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.filter_alt_off_outlined, size: 17),
              label: const Text('Clear filters'),
            ),
          ),
        ],
      ],
    ),
  );
}

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.shown,
    required this.total,
    required this.filtered,
  });

  final int shown;
  final int total;
  final bool filtered;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const Expanded(
        child: Text(
          'All vacancies',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      Text(
        filtered ? '$shown of $total' : '$total total',
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 48),
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

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });
  final JobVacancy job;
  final VoidCallback onTap, onEdit, onDelete;

  Color get _statusBackground => switch (job.status.toLowerCase()) {
    'draft' => const Color(0xFFFFFBEB),
    'closed' => const Color(0xFFF1F5F9),
    _ => const Color(0xFFECFDF5),
  };

  Color get _statusColor => switch (job.status.toLowerCase()) {
    'draft' => const Color(0xFFB45309),
    'closed' => const Color(0xFF475569),
    _ => const Color(0xFF047857),
  };

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.status,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Vacancy actions',
                  onSelected: (value) =>
                      value == 'edit' ? onEdit() : onDelete(),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFDC2626),
                        ),
                        title: Text(
                          'Delete',
                          style: TextStyle(color: Color(0xFFDC2626)),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              job.department,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _Meta(Icons.location_on_outlined, job.location),
                _Meta(Icons.schedule_rounded, job.employmentType),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            Row(
              children: [
                const Icon(
                  Icons.groups_outlined,
                  size: 18,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 6),
                Text(
                  '${job.applicantsCount} applicants',
                  style: const TextStyle(
                    color: Color(0xFF047857),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Text(
                  'View details',
                  style: TextStyle(
                    color: Color(0xFF059669),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF059669),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
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
      Icon(icon, size: 14, color: const Color(0xFF64748B)),
      const SizedBox(width: 4),
      Text(
        text,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
      ),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.filtered,
    required this.onClear,
    required this.onCreate,
  });

  final bool filtered;
  final VoidCallback onClear;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      children: [
        const CircleAvatar(
          radius: 31,
          backgroundColor: Color(0xFFD1FAE5),
          child: Icon(
            Icons.work_outline_rounded,
            color: Color(0xFF059669),
            size: 30,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          filtered ? 'No matching vacancies' : 'No job vacancies yet',
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          filtered
              ? 'Try changing your search or clearing the selected filters.'
              : 'Create your first vacancy to start building a candidate pipeline.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        if (filtered)
          OutlinedButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.filter_alt_off_outlined, size: 17),
            label: const Text('Clear filters'),
          )
        else
          FilledButton.icon(
            onPressed: onCreate,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
            ),
            icon: const Icon(Icons.add_rounded, size: 17),
            label: const Text('Create job'),
          ),
      ],
    ),
  );
}
