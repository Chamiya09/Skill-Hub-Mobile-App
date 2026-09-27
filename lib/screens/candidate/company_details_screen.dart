import 'package:flutter/material.dart';

import '../../models/company_profile.dart';
import '../../models/job.dart';
import '../../services/company_profile_service.dart';
import 'job_view_screen.dart';

const _emerald = Color(0xFF10B981);
const _emeraldDark = Color(0xFF047857);
const _ink = Color(0xFF0F172A);
const _body = Color(0xFF64748B);

class CompanyDetailsScreen extends StatefulWidget {
  const CompanyDetailsScreen({super.key, required this.identifier});
  final String identifier;

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  late final CompanyProfileService _service;
  late Future<CompanyProfile> _profileFuture;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _service = CompanyProfileService();
    _profileFuture = _loadProfile();
  }

  Future<CompanyProfile> _loadProfile() =>
      _service.getProfile(widget.identifier);

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _profileFuture = _loadProfile());
    await _profileFuture;
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
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF334155),
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
                  'EMPLOYER PROFILE',
                  style: TextStyle(
                    color: _emerald,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Company Details',
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
          _CompanyTitleIcon(),
        ],
      ),
    ),
    body: FutureBuilder<CompanyProfile>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _emerald),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return _CompanyState(onRetry: _refresh);
        }
        final profile = snapshot.data!;
        final query = _search.trim().toLowerCase();
        final jobs = query.isEmpty
            ? profile.jobs
            : profile.jobs
                  .where(
                    (job) =>
                        '${job.title} ${job.department} ${job.location} ${job.employmentType} ${job.tags.join(' ')}'
                            .toLowerCase()
                            .contains(query),
                  )
                  .toList();
        return RefreshIndicator(
          color: _emerald,
          onRefresh: _refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
            children: [
              _CompanyHero(profile: profile, jobCount: profile.jobs.length),
              const SizedBox(height: 16),
              _CompanySection(
                title: 'About ${profile.companyName}',
                subtitle: 'Company mission, culture, and background',
                icon: Icons.business_outlined,
                child: Text(
                  profile.about?.isNotEmpty == true
                      ? profile.about!
                      : 'No detailed company overview has been published yet.',
                  style: const TextStyle(
                    color: _body,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _CompanySection(
                title: 'Open Positions',
                subtitle:
                    'Explore active opportunities at ${profile.companyName}',
                icon: Icons.work_outline_rounded,
                child: Column(
                  children: [
                    if (profile.jobs.length > 2) ...[
                      TextField(
                        onChanged: (value) => setState(() => _search = value),
                        decoration: InputDecoration(
                          hintText: 'Search roles...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (jobs.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'No active positions match this search.',
                          style: TextStyle(color: _body, fontSize: 12),
                        ),
                      )
                    else
                      ...jobs.map((job) => _JobRow(job: job)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _CompanySection(
                title: 'Company Details & Links',
                subtitle: 'Public contact and organization information',
                icon: Icons.language_rounded,
                child: Column(
                  children: [
                    if (profile.location?.isNotEmpty == true)
                      _InfoRow(Icons.location_on_outlined, profile.location!),
                    if (profile.industry?.isNotEmpty == true)
                      _InfoRow(Icons.category_outlined, profile.industry!),
                    if (profile.companySize?.isNotEmpty == true)
                      _InfoRow(Icons.groups_outlined, profile.companySize!),
                    if (profile.contactEmail.isNotEmpty)
                      _InfoRow(
                        Icons.mail_outline_rounded,
                        profile.contactEmail,
                      ),
                    if (profile.website?.isNotEmpty == true)
                      _InfoRow(Icons.public_rounded, profile.website!),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _CompanyHero extends StatelessWidget {
  const _CompanyHero({required this.profile, required this.jobCount});
  final CompanyProfile profile;
  final int jobCount;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [_emeraldDark, _emerald],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(22),
      boxShadow: const [
        BoxShadow(
          color: Color(0x3310B981),
          blurRadius: 18,
          offset: Offset(0, 7),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
          ),
          child: profile.logoUrl?.isNotEmpty == true
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Image.network(
                    profile.logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _Initials(profile.initials),
                  ),
                )
              : _Initials(profile.initials),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.companyName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                profile.industry ?? 'Verified employer on Skill Hub',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 12),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0x26FFFFFF),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: Text(
                  '$jobCount open ${jobCount == 1 ? 'position' : 'positions'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
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

class _CompanySection extends StatelessWidget {
  const _CompanySection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  @override
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080F172A),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
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
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _JobRow extends StatelessWidget {
  const _JobRow({required this.job});
  final Job job;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => JobViewScreen(initialJob: job)),
    ),
    borderRadius: BorderRadius.circular(14),
    child: Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${job.department} • ${job.location}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _body, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _emeraldDark),
        ],
      ),
    ),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.value);
  final IconData icon;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, color: _emeraldDark, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: _body, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _Initials extends StatelessWidget {
  const _Initials(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      value.isEmpty ? 'CO' : value,
      style: const TextStyle(
        color: _emeraldDark,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}

class _CompanyTitleIcon extends StatelessWidget {
  const _CompanyTitleIcon();
  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [_emerald, _emeraldDark]),
      borderRadius: BorderRadius.circular(13),
      boxShadow: const [
        BoxShadow(
          color: Color(0x3310B981),
          blurRadius: 12,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: const Icon(Icons.business_outlined, color: Colors.white, size: 21),
  );
}

class _CompanyState extends StatelessWidget {
  const _CompanyState({required this.onRetry});
  final Future<void> Function() onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.business_outlined, color: _emerald, size: 48),
          const SizedBox(height: 14),
          const Text(
            'Company details unavailable',
            style: TextStyle(
              color: _ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check your connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _body, fontSize: 13),
          ),
          const SizedBox(height: 18),
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
