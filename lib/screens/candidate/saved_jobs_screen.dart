import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../models/saved_job.dart';
import '../../services/saved_jobs_service.dart';
import 'find_jobs_screen.dart';
import 'job_view_screen.dart';

const _emerald = Color(0xFF10B981);
const _emeraldDark = Color(0xFF047857);
const _ink = Color(0xFF0F172A);
const _muted = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key, required this.token});
  final String token;
  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  late final SavedJobsService _service = SavedJobsService(token: widget.token);
  List<SavedJob> _jobs = const [];
  final Set<String> _removing = {};
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
      final jobs = await _service.getAll();
      if (mounted) setState(() => _jobs = jobs);
    } on SavedJobsException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _remove(SavedJob job) async {
    final previous = _jobs;
    setState(() {
      _removing.add(job.jobId);
      _jobs = _jobs.where((item) => item.jobId != job.jobId).toList();
    });
    try {
      await _service.remove(job.jobId);
    } on SavedJobsException catch (error) {
      if (mounted) {
        setState(() {
          _jobs = previous;
          _error = error.message;
        });
      }
    } finally {
      if (mounted) setState(() => _removing.remove(job.jobId));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
            onTap: () => Navigator.pop(context),
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
                  'SAVED BOOKMARKS',
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
                  'Saved Jobs',
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
          _Hero(count: _jobs.length, onBrowse: _browse),
          const SizedBox(height: 18),
          if (_error != null) _ErrorCard(message: _error!, onRetry: _load),
          if (_loading) ...List.generate(3, (_) => const _Skeleton()),
          if (!_loading && _error == null && _jobs.isEmpty)
            _EmptyState(onBrowse: _browse),
          if (!_loading && _error == null)
            ..._jobs.map(
              (job) => Padding(
                padding: const EdgeInsets.only(bottom: 13),
                child: _SavedJobCard(
                  job: job,
                  removing: _removing.contains(job.jobId),
                  onRemove: () => _remove(job),
                  onView: () => _view(job),
                ),
              ),
            ),
        ],
      ),
    ),
  );

  void _browse() => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const FindJobsScreen()));
  void _view(SavedJob saved) {
    final job = Job(
      id: saved.jobId,
      companyId: '',
      companyName: saved.companyName,
      title: saved.jobTitle,
      department: '',
      location: saved.location,
      employmentType: saved.employmentType,
      experienceLevel: saved.experienceLevel,
      salaryRange: saved.salaryRange,
      createdAt: saved.postedAt,
      logoUrl: saved.companyLogoUrl,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => JobViewScreen(initialJob: job)),
    );
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
    child: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 21),
  );
}

class _Hero extends StatelessWidget {
  const _Hero({required this.count, required this.onBrowse});
  final int count;
  final VoidCallback onBrowse;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Colors.white, Color(0xFFEFFCF7)]),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFDCE7E3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_border_rounded,
                color: _emeraldDark,
                size: 14,
              ),
              SizedBox(width: 6),
              Text(
                'SAVED BOOKMARKS',
                style: TextStyle(
                  color: _emeraldDark,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 11),
        const Text(
          'Saved Jobs',
          style: TextStyle(
            color: _ink,
            fontSize: 25,
            fontWeight: FontWeight.w900,
            letterSpacing: -.7,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Keep promising opportunities organised and return when you are ready to apply.',
          style: TextStyle(color: _muted, fontSize: 12.5, height: 1.55),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text.rich(
              TextSpan(
                style: const TextStyle(color: _muted, fontSize: 11),
                children: [
                  TextSpan(text: 'Private to your account  •  '),
                  TextSpan(
                    text: '$count saved',
                    style: const TextStyle(
                      color: _emeraldDark,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.search_rounded, size: 17),
              label: const Text(
                'Browse Jobs',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SavedJobCard extends StatelessWidget {
  const _SavedJobCard({
    required this.job,
    required this.removing,
    required this.onRemove,
    required this.onView,
  });
  final SavedJob job;
  final bool removing;
  final VoidCallback onRemove;
  final VoidCallback onView;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFDCE7E3)),
      borderRadius: BorderRadius.circular(18),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 28,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFECFDF5), Color(0xFFF0FDFA)],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: job.companyLogoUrl?.isNotEmpty == true
                  ? Image.network(
                      job.companyLogoUrl!,
                      fit: BoxFit.cover,
                      width: 52,
                      height: 52,
                      errorBuilder: (_, _, _) => _Initials(job.companyInitials),
                    )
                  : _Initials(job.companyInitials),
            ),
            const Spacer(),
            IconButton(
              onPressed: removing ? null : onRemove,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFEF4444),
                side: const BorderSide(color: Color(0xFFFECACA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: removing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFEF4444),
                      ),
                    )
                  : const Icon(Icons.delete_outline_rounded, size: 19),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (job.experienceLevel.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: _border),
            ),
            child: Text(
              job.experienceLevel.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .4,
              ),
            ),
          ),
        const SizedBox(height: 9),
        Text(
          job.jobTitle,
          style: const TextStyle(
            color: _ink,
            fontSize: 17,
            height: 1.35,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            const Icon(Icons.business_outlined, color: _muted, size: 15),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                job.companyName,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 13,
          runSpacing: 7,
          children: [
            _Meta(Icons.location_on_outlined, job.location),
            _Meta(Icons.schedule_rounded, job.employmentType),
          ],
        ),
        if (job.salaryRange?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 10),
          Text(
            job.salaryRange!,
            style: const TextStyle(
              color: _emeraldDark,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
        const SizedBox(height: 15),
        const Divider(height: 1, color: Color(0xFFEDF1F5)),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Saved ${_date(job.savedAt)}',
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10.5,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onView,
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.arrow_forward_rounded, size: 15),
              label: const Text(
                'View Job',
                style: TextStyle(
                  color: _emeraldDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

String _date(DateTime? date) {
  if (date == null) return 'recently';
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

class _Initials extends StatelessWidget {
  const _Initials(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Text(
    value.isEmpty ? 'SH' : value,
    style: const TextStyle(
      color: _emeraldDark,
      fontSize: 15,
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
        style: const TextStyle(color: _muted, fontSize: 11),
      ),
    ],
  );
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();
  @override
  Widget build(BuildContext context) => Container(
    height: 265,
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

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFFFECACA)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFF991B1B), fontSize: 11),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onBrowse});
  final VoidCallback onBrowse;
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
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFECFDF5), Color(0xFFF0FDFA)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: const Icon(
            Icons.bookmark_border_rounded,
            color: _emerald,
            size: 29,
          ),
        ),
        const SizedBox(height: 17),
        const Text(
          'No Bookmarked Jobs',
          style: TextStyle(
            color: _ink,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Use the bookmark button on any vacancy to build your personal opportunity shortlist.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 12, height: 1.6),
        ),
        const SizedBox(height: 17),
        FilledButton.icon(
          onPressed: onBrowse,
          style: FilledButton.styleFrom(backgroundColor: _emerald),
          icon: const Icon(Icons.search_rounded, size: 18),
          label: const Text('Explore Job Directory'),
        ),
      ],
    ),
  );
}
