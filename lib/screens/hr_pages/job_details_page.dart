import 'package:flutter/material.dart';

import '../../models/job_vacancy.dart';
import '../../widgets/hr_mobile_ui.dart';

class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({super.key, required this.job});
  final JobVacancy job;

  @override
  Widget build(BuildContext context) => HrSheet(
    title: 'Job Details',
    footer: HrSaveButton(
      label: 'Done',
      onPressed: () => Navigator.pop(context),
    ),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        _Hero(job),
        const SizedBox(height: 14),
        HrResponsiveTiles(
          children: [
            _Spec(
              Icons.payments_outlined,
              'SALARY',
              job.salaryRange ?? 'Not disclosed',
            ),
            _Spec(
              Icons.groups_outlined,
              'APPLICANTS',
              '${job.applicantsCount}',
            ),
            _Spec(
              Icons.work_outline_rounded,
              'EXPERIENCE',
              job.experienceLevel,
            ),
            _Spec(
              Icons.calendar_today_outlined,
              'POSTED',
              _date(job.createdAt),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _Section(
          icon: Icons.article_outlined,
          title: 'About the Position',
          child: RichJobText(
            job.description.isEmpty
                ? 'No description provided for this vacancy.'
                : job.description,
          ),
        ),
        if (job.whatWeOffer?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 14),
          _Section(
            icon: Icons.volunteer_activism_outlined,
            title: 'What We Offer & Perks',
            child: RichJobText(job.whatWeOffer!, benefits: true),
          ),
        ],
        const SizedBox(height: 14),
        _Section(
          icon: Icons.admin_panel_settings_outlined,
          title: 'Requisition Details',
          child: Column(
            children: [
              _Info('Department', job.department),
              _Info('Employment type', job.employmentType),
              _Info('Status', job.status, last: true),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Hero extends StatelessWidget {
  const _Hero(this.job);
  final JobVacancy job;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Column(
      children: [
        Container(
          height: 5,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF38BDF8)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  _Badge(job.status, green: true),
                  _Badge(job.department),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                job.companyName ?? 'Company',
                style: const TextStyle(
                  color: Color(0xFF059669),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                job.title,
                style: const TextStyle(
                  color: Color(0xFF0B1329),
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 14,
                runSpacing: 10,
                children: [
                  _Meta(Icons.location_on_outlined, job.location),
                  _Meta(Icons.schedule_rounded, job.employmentType),
                  _Meta(Icons.work_outline_rounded, job.experienceLevel),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class RichJobText extends StatelessWidget {
  const RichJobText(this.source, {super.key, this.benefits = false});
  final String source;
  final bool benefits;

  List<({String text, bool heading, bool bullet})> _lines() {
    var value = source.replaceAll('\r', '');
    value = value.replaceAllMapped(
      RegExp(
        r'<h[1-6][^>]*>(.*?)</h[1-6]>',
        caseSensitive: false,
        dotAll: true,
      ),
      (m) => '\n§${m[1]}\n',
    );
    value = value.replaceAllMapped(
      RegExp(r'<li[^>]*>(.*?)</li>', caseSensitive: false, dotAll: true),
      (m) => '\n• ${m[1]}\n',
    );
    value = value
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(
          RegExp(r'</?(p|div|ul|ol)[^>]*>', caseSensitive: false),
          '\n',
        )
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
    return value
        .split('\n')
        .map((raw) {
          var text = raw.trim();
          final heading = text.startsWith('§');
          if (heading) text = text.substring(1).trim();
          final bullet = RegExp(r'^(•|[-*–—]\s+|\d+[.)]\s+)').hasMatch(text);
          text = text.replaceFirst(RegExp(r'^(•\s*|[-*–—]\s+|\d+[.)]\s+)'), '');
          return (text: text, heading: heading, bullet: bullet);
        })
        .where((line) => line.text.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: _lines().map((line) {
      if (line.heading) {
        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 5),
          child: Text(
            line.text,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      }
      if (line.bullet || benefits) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 1),
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  benefits ? Icons.check_rounded : Icons.circle,
                  size: benefits ? 14 : 7,
                  color: const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  line.text,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 14,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Text(
          line.text,
          style: const TextStyle(
            color: Color(0xFF334155),
            fontSize: 14,
            height: 1.7,
          ),
        ),
      );
    }).toList(),
  );
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });
  final IconData icon;
  final String title;
  final Widget child;
  @override
  Widget build(BuildContext context) => HrCard(
    padding: EdgeInsets.zero,
    child: ExpansionTile(
      key: PageStorageKey('job-details-$title'),
      initiallyExpanded: true,
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      leading: Icon(icon, color: hrEmerald),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      children: [child],
    ),
  );
}

class _Spec extends StatelessWidget {
  const _Spec(this.icon, this.label, this.value);
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: const Color(0xFF059669), size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.text, {this.green = false});
  final String text;
  final bool green;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: green ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: green ? const Color(0xFF047857) : const Color(0xFF2563EB),
        fontSize: 10,
        fontWeight: FontWeight.w700,
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
      Icon(icon, size: 16, color: const Color(0xFF64748B)),
      const SizedBox(width: 5),
      Flexible(
        child: Text(
          text,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
        ),
      ),
    ],
  );
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value, {this.last = false});
  final String label, value;
  final bool last;
  @override
  Widget build(BuildContext context) =>
      Align(alignment: Alignment.centerLeft, child: HrDetail(label, value));
}

String _date(DateTime? date) {
  if (date == null) return 'Unavailable';
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
