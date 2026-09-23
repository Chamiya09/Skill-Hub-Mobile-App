import 'package:flutter/material.dart';

import '../../services/candidate_cv_service.dart';

const _emerald = Color(0xFF10B981);
const _emeraldDark = Color(0xFF047857);
const _ink = Color(0xFF0F172A);
const _body = Color(0xFF64748B);
const _border = Color(0xFFE2E8F0);
const _surface = Color(0xFFF8FAFC);

class DigitalCvScreen extends StatefulWidget {
  const DigitalCvScreen({super.key, required this.token});

  final String token;

  @override
  State<DigitalCvScreen> createState() => _DigitalCvScreenState();
}

class _DigitalCvScreenState extends State<DigitalCvScreen> {
  late final CandidateCvService _service;
  late Future<CandidateCvProfile> _profileFuture;

  @override
  void initState() {
    super.initState();
    _service = CandidateCvService();
    _profileFuture = _service.getProfile(widget.token);
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _profileFuture = _service.getProfile(widget.token));
    await _profileFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 76,
        leadingWidth: 62,
        titleSpacing: 10,
        shape: const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
        leading: Padding(
          padding: const EdgeInsets.only(left: 14, top: 14, bottom: 14),
          child: Material(
            color: _surface,
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
                    'CAREER PROFILE',
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
                    'My Digital CV',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: _ink,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 11),
            _DigitalCvTitleIcon(),
          ],
        ),
      ),
      body: FutureBuilder<CandidateCvProfile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _emerald),
            );
          }
          if (snapshot.hasError) {
            return _ErrorState(onRetry: _refresh);
          }
          final profile = snapshot.data;
          if (profile == null) return _ErrorState(onRetry: _refresh);
          return RefreshIndicator(
            color: _emerald,
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 34),
              children: [
                _ProfileHero(profile: profile),
                if (profile.summary?.isNotEmpty == true ||
                    profile.highlights.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Professional Summary',
                    subtitle: 'Your career story at a glance',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (profile.summary?.isNotEmpty == true)
                          _DescriptionPoints(
                            description: profile.summary!,
                            label: 'Description',
                          ),
                        if (profile.highlights.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.highlights
                                .map((item) => _HighlightTile(item: item))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (profile.experiences.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.work_history_rounded,
                    title: 'Experience',
                    subtitle: 'Your professional journey',
                    child: Column(
                      children: profile.experiences
                          .map((item) => _ExperienceTile(item: item))
                          .toList(),
                    ),
                  ),
                ],
                if (profile.educations.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.school_rounded,
                    title: 'Education',
                    subtitle: 'Academic background',
                    child: Column(
                      children: profile.educations
                          .map((item) => _EducationTile(item: item))
                          .toList(),
                    ),
                  ),
                ],
                if (profile.skills.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.psychology_rounded,
                    title: 'Skills',
                    subtitle: 'Your strongest capabilities',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: profile.skills
                          .map((skill) => _SkillChip(skill: skill))
                          .toList(),
                    ),
                  ),
                ],
                if (profile.projects.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.folder_copy_rounded,
                    title: 'Projects',
                    subtitle: 'Work you are proud of',
                    child: Column(
                      children: profile.projects
                          .map((item) => _ProjectTile(item: item))
                          .toList(),
                    ),
                  ),
                ],
                if (profile.certifications.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _SectionCard(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Certifications',
                    subtitle: 'Verified learning and credentials',
                    child: Column(
                      children: profile.certifications
                          .map((item) => _CertificationTile(item: item))
                          .toList(),
                    ),
                  ),
                ],
                if (profile.summary == null &&
                    profile.experiences.isEmpty &&
                    profile.educations.isEmpty &&
                    profile.skills.isEmpty &&
                    profile.projects.isEmpty &&
                    profile.certifications.isEmpty)
                  const _EmptyCvState(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DigitalCvTitleIcon extends StatelessWidget {
  const _DigitalCvTitleIcon();

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
    child: const Icon(Icons.badge_outlined, color: Colors.white, size: 21),
  );
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});
  final CandidateCvProfile profile;

  @override
  Widget build(BuildContext context) {
    final initial = profile.fullName.trim().isEmpty
        ? '?'
        : profile.fullName.trim()[0].toUpperCase();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_emeraldDark, _emerald],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3310B981),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                backgroundImage: profile.avatarUrl?.isNotEmpty == true
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl?.isNotEmpty == true
                    ? null
                    : Text(
                        initial,
                        style: const TextStyle(
                          color: _emeraldDark,
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.headline ?? 'Skill Hub Candidate',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xD9FFFFFF),
                        fontSize: 13,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ContactPill(
                icon: Icons.verified_rounded,
                label: 'Verified profile',
              ),
              if (profile.availability?.isNotEmpty == true)
                _ContactPill(
                  icon: Icons.bolt_rounded,
                  label: profile.availability!,
                ),
              if (profile.location?.isNotEmpty == true)
                _ContactPill(
                  icon: Icons.location_on_outlined,
                  label: profile.location!,
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (profile.email.isNotEmpty)
            _ContactLine(
              icon: Icons.mail_outline_rounded,
              label: profile.email,
            ),
          if (profile.phone?.isNotEmpty == true)
            _ContactLine(icon: Icons.phone_outlined, label: profile.phone!),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _emeraldDark, size: 21),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _body, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        child,
      ],
    ),
  );
}

class _HighlightTile extends StatelessWidget {
  const _HighlightTile({required this.item});
  final CandidateCvHighlight item;
  @override
  Widget build(BuildContext context) => Container(
    width: 145,
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: _surface,
      borderRadius: BorderRadius.circular(13),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _emeraldDark,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          item.category,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _ink,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (item.subtext?.isNotEmpty == true)
          Text(
            item.subtext!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _body, fontSize: 10),
          ),
      ],
    ),
  );
}

class _ExperienceTile extends StatelessWidget {
  const _ExperienceTile({required this.item});
  final CandidateCvExperience item;
  @override
  Widget build(BuildContext context) => _TimelineTile(
    icon: Icons.work_outline_rounded,
    title: item.jobTitle,
    subtitle: [
      item.company,
      if (item.location?.isNotEmpty == true) item.location!,
    ].join(' • '),
    period:
        '${item.startDate ?? ''} - ${item.isCurrent ? 'Present' : item.endDate ?? ''}',
    description: item.description,
  );
}

class _EducationTile extends StatelessWidget {
  const _EducationTile({required this.item});
  final CandidateCvEducation item;
  @override
  Widget build(BuildContext context) => _TimelineTile(
    icon: Icons.school_outlined,
    title: item.degree,
    subtitle: item.institution,
    period: item.year,
    description: null,
  );
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.period,
    this.description,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String? period;
  final String? description;
  @override
  Widget build(BuildContext context) {
    final points = _descriptionPoints(description);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _emeraldDark, size: 17),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _emeraldDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (points.isNotEmpty)
                  _DescriptionPoints(description: description!),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionPoints extends StatelessWidget {
  const _DescriptionPoints({
    required this.description,
    this.label = 'Description',
  });

  final String description;
  final String label;

  @override
  Widget build(BuildContext context) {
    final points = _descriptionPoints(description);
    if (points.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _ink,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6, right: 7),
                  child: Icon(Icons.circle, color: _emerald, size: 5),
                ),
                Expanded(
                  child: Text(
                    point,
                    style: const TextStyle(
                      color: _body,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

List<String> _descriptionPoints(String? rawDescription) {
  if (rawDescription == null || rawDescription.trim().isEmpty) return const [];

  var text = rawDescription
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(
        RegExp(r'</?(li|p|div|h[1-6])[^>]*>', caseSensitive: false),
        '\n',
      )
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>');

  final lines = text
      .split(RegExp(r'\r?\n|[•▪●]'))
      .map((line) => line.replaceFirst(RegExp(r'^\s*[-*]\s*'), '').trim())
      .where((line) => line.isNotEmpty)
      .toList();

  if (lines.length > 1) return lines;
  return lines.first
      .split(RegExp(r'(?<=[.!?])\s+(?=[A-Z0-9])'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.skill});
  final CandidateCvSkill skill;
  @override
  Widget build(BuildContext context) => Chip(
    label: Text(
      skill.name,
      style: const TextStyle(
        color: _emeraldDark,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
    backgroundColor: const Color(0xFFECFDF5),
    side: BorderSide.none,
    visualDensity: VisualDensity.compact,
    padding: const EdgeInsets.symmetric(horizontal: 5),
  );
}

class _ProjectTile extends StatelessWidget {
  const _ProjectTile({required this.item});
  final CandidateCvProject item;
  @override
  Widget build(BuildContext context) => _TimelineTile(
    icon: Icons.folder_outlined,
    title: item.name,
    subtitle: item.role ?? 'Project',
    description: item.description,
  );
}

class _CertificationTile extends StatelessWidget {
  const _CertificationTile({required this.item});
  final CandidateCvCertification item;
  @override
  Widget build(BuildContext context) => _TimelineTile(
    icon: Icons.workspace_premium_outlined,
    title: item.title,
    subtitle: item.organization,
    period: item.date,
  );
}

class _ContactPill extends StatelessWidget {
  const _ContactPill({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0x26FFFFFF),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 13),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _ContactLine extends StatelessWidget {
  const _ContactLine({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xCCFFFFFF), size: 15),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 11),
          ),
        ),
      ],
    ),
  );
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: _body, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Unable to load your Digital CV',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _ink,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _body, fontSize: 13),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try again'),
            style: FilledButton.styleFrom(backgroundColor: _emeraldDark),
          ),
        ],
      ),
    ),
  );
}

class _EmptyCvState extends StatelessWidget {
  const _EmptyCvState();
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _border),
    ),
    child: const Column(
      children: [
        Icon(Icons.badge_outlined, color: _emerald, size: 42),
        SizedBox(height: 10),
        Text(
          'Your Digital CV is ready to build',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Add experience, education, projects, and skills from the web dashboard to make your profile stand out.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _body, fontSize: 12, height: 1.4),
        ),
      ],
    ),
  );
}
