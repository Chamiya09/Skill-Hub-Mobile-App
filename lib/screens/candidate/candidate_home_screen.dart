import 'package:flutter/material.dart';

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
  final Set<int> _savedJobs = <int>{1};

  static const _jobs = [
    _JobPreview(
      role: 'Flutter Developer',
      company: 'Nova Technologies',
      location: 'Colombo, Sri Lanka',
      workMode: 'Hybrid',
      salary: 'LKR 180K - 260K',
      match: 94,
      posted: '2h ago',
      skills: ['Flutter', 'Dart', 'REST API'],
      logoText: 'N',
    ),
    _JobPreview(
      role: 'Associate Software Engineer',
      company: 'Vertex Labs',
      location: 'Remote',
      workMode: 'Full-time',
      salary: 'LKR 150K - 220K',
      match: 88,
      posted: '1d ago',
      skills: ['C#', '.NET', 'PostgreSQL'],
      logoText: 'V',
    ),
    _JobPreview(
      role: 'Mobile Application Intern',
      company: 'Cloud Nine Digital',
      location: 'Kandy, Sri Lanka',
      workMode: 'On-site',
      salary: 'Paid internship',
      match: 82,
      posted: '2d ago',
      skills: ['Mobile', 'Git', 'UI/UX'],
      logoText: 'C',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: CustomScrollView(
        key: const PageStorageKey('candidate-home-scroll'),
        physics: const BouncingScrollPhysics(),
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
                  onSearch: (query) => _showMessage(
                    query.isEmpty ? 'Opening all jobs.' : 'Searching for "$query".',
                  ),
                ),
                const SizedBox(height: 18),
                const _TrustHighlights(),
                const SizedBox(height: 32),
                const _FeatureStrip(),
                const SizedBox(height: 34),
                _SectionHeader(
                  title: 'Top live opportunities',
                  subtitle: 'FEATURED ROLES',
                  actionLabel: 'View all',
                  onAction: () => _showMessage('Opening all available jobs.'),
                ),
                const SizedBox(height: 14),
                ...List<int>.generate(_jobs.length, (index) => index).map(
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _JobCard(
                      job: _jobs[index],
                      isSaved: _savedJobs.contains(index),
                      onSave: () {
                        setState(() {
                          if (!_savedJobs.add(index)) _savedJobs.remove(index);
                        });
                      },
                      onView: () =>
                          _showMessage('${_jobs[index].role} selected.'),
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              onSubmitted: widget.onSearch,
              style: const TextStyle(color: _ink, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Jobs, companies, or skills...',
                hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            height: 46,
            child: IconButton.filled(
              tooltip: 'Search jobs',
              onPressed: () => widget.onSearch(_controller.text.trim()),
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
  const _TrustHighlights();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 8,
      children: [
        _TrustItem(label: 'Verified roles'),
        _TrustItem(label: 'AI matching'),
        _TrustItem(label: 'Direct employers'),
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
    (Icons.track_changes_rounded, 'AI Match Scoring', 'Roles ranked against your skills.'),
    (Icons.bolt_rounded, 'Instant Applications', 'Apply directly without middlemen.'),
    (Icons.trending_up_rounded, 'Real-time Tracking', 'Follow every application update.'),
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

  final _JobPreview job;
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
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFD1FAE5)),
                ),
                child: Text(
                  job.logoText,
                  style: const TextStyle(
                    color: _emeraldDark,
                    fontSize: 19,
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
                      job.role,
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
                      job.company,
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
                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
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
              _MetaPill(icon: Icons.business_center_outlined, label: job.workMode),
            ],
          ),
          const SizedBox(height: 13),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: job.skills
                .map(
                  (skill) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
                      job.salary,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Posted ${job.posted}',
                      style: const TextStyle(color: _bodyText, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${job.match}% Match',
                  style: const TextStyle(
                    color: _emeraldDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onView,
                style: FilledButton.styleFrom(
                  backgroundColor: _emerald,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

class _JobPreview {
  const _JobPreview({
    required this.role,
    required this.company,
    required this.location,
    required this.workMode,
    required this.salary,
    required this.match,
    required this.posted,
    required this.skills,
    required this.logoText,
  });

  final String role;
  final String company;
  final String location;
  final String workMode;
  final String salary;
  final int match;
  final String posted;
  final List<String> skills;
  final String logoText;
}
