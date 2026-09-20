import 'package:flutter/material.dart';

import '../../models/job.dart';
import '../../services/public_jobs_service.dart';

const _emerald = Color(0xFF10B981);
const _emeraldDark = Color(0xFF047857);
const _ink = Color(0xFF0F172A);
const _body = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);
const _background = Color(0xFFF8FAFC);

class JobViewScreen extends StatefulWidget {
  const JobViewScreen({super.key, required this.initialJob});

  final Job initialJob;

  @override
  State<JobViewScreen> createState() => _JobViewScreenState();
}

class _JobViewScreenState extends State<JobViewScreen> {
  final PublicJobsService _service = PublicJobsService();
  late Job _job;
  bool _loading = true;
  bool _saved = false;
  bool _applied = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _job = widget.initialJob;
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final job = await _service.getJobById(widget.initialJob.id);
      if (mounted) setState(() => _job = job);
    } on JobsApiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back to jobs',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded, color: _ink),
        ),
        title: const Text('Job details', style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: _saved ? 'Remove saved job' : 'Save job',
            onPressed: () => setState(() => _saved = !_saved),
            icon: Icon(_saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: _saved ? _emerald : _body),
          ),
          IconButton(
            tooltip: 'Share job',
            onPressed: () => _message('Job sharing will be available soon.'),
            icon: const Icon(Icons.ios_share_rounded, color: _body),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: _emerald,
        onRefresh: _loadDetails,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
          children: [
            if (_loading) const LinearProgressIndicator(color: _emerald, backgroundColor: Color(0xFFD1FAE5)),
            if (_error != null) ...[
              _Notice(message: 'Showing saved job information. ${_error!}'),
              const SizedBox(height: 14),
            ],
            _HeroCard(job: _job),
            const SizedBox(height: 16),
            _MatchCard(onTap: () => _message('AI match analysis is coming soon.')),
            const SizedBox(height: 16),
            _ContentCard(
              title: 'About the role',
              child: Text(
                _plainText(_job.description, fallback: 'The employer has not added a detailed role description yet.'),
                style: const TextStyle(color: Color(0xFF475569), fontSize: 14, height: 1.65),
              ),
            ),
            if (_job.whatWeOffer?.trim().isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _ContentCard(
                title: 'What we offer & perks',
                child: Text(_plainText(_job.whatWeOffer!), style: const TextStyle(color: Color(0xFF475569), fontSize: 14, height: 1.65)),
              ),
            ],
            const SizedBox(height: 16),
            _OverviewCard(job: _job),
            const SizedBox(height: 16),
            _CompanyCard(job: _job),
            const SizedBox(height: 18),
            _ApplyCard(
              job: _job,
              applied: _applied,
              onApply: () {
                setState(() => _applied = true);
                _message('Application ready — Digital CV integration is coming soon.');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.job});
  final Job job;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _Logo(job: job, size: 58),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(job.companyName, style: const TextStyle(color: _ink, fontSize: 14, fontWeight: FontWeight.w800))),
              const SizedBox(width: 6),
              const Icon(Icons.verified_rounded, color: Color(0xFF2563EB), size: 17),
            ]),
            const SizedBox(height: 7),
            Text(job.title, style: const TextStyle(color: _ink, fontSize: 23, height: 1.2, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          ])),
        ]),
        const SizedBox(height: 19),
        Wrap(spacing: 14, runSpacing: 10, children: [
          _Meta(icon: Icons.location_on_outlined, text: job.location),
          _Meta(icon: Icons.schedule_rounded, text: job.employmentType),
          if (job.experienceLevel.isNotEmpty) _Meta(icon: Icons.business_center_outlined, text: job.experienceLevel),
        ]),
        if (job.tags.isNotEmpty || job.department.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(spacing: 7, runSpacing: 7, children: <String>{if (job.department.isNotEmpty) job.department, ...job.tags}.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(7), border: Border.all(color: _border)),
            child: Text(tag, style: const TextStyle(color: Color(0xFF334155), fontSize: 11, fontWeight: FontWeight.w700)),
          )).toList()),
        ],
      ]),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: const Color(0xFFECFDF5),
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFA7F3D0)), borderRadius: BorderRadius.circular(18)),
        child: const Row(children: [
          CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.auto_awesome_rounded, color: _emeraldDark, size: 20)),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Analyze my match', style: TextStyle(color: _emeraldDark, fontSize: 14, fontWeight: FontWeight.w800)),
            SizedBox(height: 3),
            Text('See how your Digital CV fits this role', style: TextStyle(color: Color(0xFF3F6F60), fontSize: 11)),
          ])),
          Icon(Icons.arrow_forward_rounded, color: _emeraldDark, size: 20),
        ]),
      ),
    ),
  );
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => _Card(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      const Divider(height: 1, color: Color(0xFFF1F5F9)),
      const SizedBox(height: 14),
      child,
    ]),
  );
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.job});
  final Job job;
  @override
  Widget build(BuildContext context) => _ContentCard(title: 'Job overview', child: Column(children: [
    _OverviewRow(icon: Icons.payments_outlined, label: 'Salary range', value: job.salaryLabel),
    _OverviewRow(icon: Icons.account_tree_outlined, label: 'Department', value: job.department.isEmpty ? 'Not specified' : job.department),
    _OverviewRow(icon: Icons.calendar_today_outlined, label: 'Date posted', value: job.postedDateLabel),
    _OverviewRow(icon: Icons.check_circle_outline_rounded, label: 'Status', value: job.status == 'Active' ? 'Active & accepting applications' : job.status, last: true, active: job.status == 'Active'),
  ]));
}

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.icon, required this.label, required this.value, this.last = false, this.active = false});
  final IconData icon; final String label; final String value; final bool last; final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.only(bottom: last ? 0 : 14, top: 2),
    margin: EdgeInsets.only(bottom: last ? 0 : 14),
    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: last ? Colors.transparent : const Color(0xFFF1F5F9)))),
    child: Row(children: [
      Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: _emeraldDark, size: 19)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: .5)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: active ? _emeraldDark : _ink, fontSize: 13, fontWeight: FontWeight.w700)),
      ])),
    ]),
  );
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.job}); final Job job;
  @override
  Widget build(BuildContext context) => _Card(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [_Logo(job: job, size: 44), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(job.companyName, style: const TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w800)),
      const SizedBox(height: 2),
      const Text('Verified organization', style: TextStyle(color: _body, fontSize: 11)),
    ])), const Icon(Icons.verified_rounded, color: Color(0xFF2563EB), size: 20)]),
    const SizedBox(height: 13),
    Text('${job.companyName} is actively hiring through Skill Hub’s verified technical talent network.', style: const TextStyle(color: _body, fontSize: 13, height: 1.5)),
  ]));
}

class _ApplyCard extends StatelessWidget {
  const _ApplyCard({required this.job, required this.applied, required this.onApply});
  final Job job; final bool applied; final VoidCallback onApply;
  @override
  Widget build(BuildContext context) => _Card(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Interested in this position?', style: TextStyle(color: _ink, fontSize: 17, fontWeight: FontWeight.w800)),
    const SizedBox(height: 7),
    Text('Submit your verified Digital CV directly to ${job.companyName}’s recruiting pipeline.', style: const TextStyle(color: _body, fontSize: 13, height: 1.5)),
    const SizedBox(height: 17),
    SizedBox(width: double.infinity, height: 50, child: FilledButton.icon(
      onPressed: applied ? null : onApply,
      style: FilledButton.styleFrom(backgroundColor: _emerald, disabledBackgroundColor: const Color(0xFFF1F5F9), disabledForegroundColor: _body, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13))),
      icon: Icon(applied ? Icons.check_circle_rounded : Icons.send_rounded, size: 19),
      label: Text(applied ? 'Application ready' : 'Apply with Digital CV', style: const TextStyle(fontWeight: FontWeight.w800)),
    )),
    const SizedBox(height: 10),
    const Center(child: Text('Fast, secure application powered by Digital CV', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10))),
  ]));
}

class _Logo extends StatelessWidget {
  const _Logo({required this.job, required this.size}); final Job job; final double size;
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size, alignment: Alignment.center, clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(size * .25), border: Border.all(color: const Color(0xFFA7F3D0))),
    child: job.logoUrl != null ? Image.network(job.logoUrl!, fit: BoxFit.cover, width: size, height: size, errorBuilder: (_, _, _) => _initials()) : _initials(),
  );
  Widget _initials() => Text(job.companyInitials, style: TextStyle(color: const Color(0xFF065F46), fontSize: size * .31, fontWeight: FontWeight.w900));
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text}); final IconData icon; final String text;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: _body), const SizedBox(width: 5), Text(text, style: const TextStyle(color: _body, fontSize: 12, fontWeight: FontWeight.w600))]);
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.padding}); final Widget child; final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, padding: padding, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border), boxShadow: const [BoxShadow(color: Color(0x080F172A), blurRadius: 18, offset: Offset(0, 5))]), child: child);
}

class _Notice extends StatelessWidget {
  const _Notice({required this.message}); final String message;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFDE68A))), child: Row(children: [const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 19), const SizedBox(width: 9), Expanded(child: Text(message, style: const TextStyle(color: Color(0xFF92400E), fontSize: 11, height: 1.4)))]));
}

String _plainText(String value, {String fallback = ''}) {
  final text = value
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</(p|li|div|h[1-6])>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<li[^>]*>', caseSensitive: false), '• ')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll(RegExp(r'\n\s*\n\s*\n+'), '\n\n')
      .trim();
  return text.isEmpty ? fallback : text;
}
