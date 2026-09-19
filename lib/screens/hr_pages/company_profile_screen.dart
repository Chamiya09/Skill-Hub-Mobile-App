import 'package:flutter/material.dart';

import '../../widgets/hr_mobile_ui.dart';

import '../../models/company_profile.dart';
import '../../services/company_account_service.dart';

const _industries = [
  'Software Development & SaaS',
  'Information Technology & Services',
  'Financial Technology (FinTech)',
  'Artificial Intelligence & Machine Learning',
  'Healthcare & Biotechnology',
  'E-Commerce & Digital Retail',
  'Cloud Infrastructure & DevOps',
  'Cybersecurity',
  'Telecommunications',
  'Education & EdTech',
  'Media & Entertainment',
  'Consulting & Professional Services',
  'Other',
];

const _companySizes = [
  '1-10 Employees (Seed Stage)',
  '11-50 Employees (Early Stage)',
  '51-200 Employees (Growth Stage)',
  '201-500 Employees (Scale-up)',
  '501-1000 Employees (Enterprise)',
  '1000+ Employees (Global Enterprise)',
];

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key, this.service});
  final CompanyAccountService? service;

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  late final _service = widget.service ?? CompanyAccountService();
  CompanyProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _service.getProfile();
      if (mounted) setState(() => _profile = profile);
    } on CompanyAccountException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openEditor() async {
    final profile = _profile;
    if (profile == null) return;
    final updated = await showHrSheet<CompanyProfile>(
      context,
      builder: (_) =>
          _CompanyProfileEditor(profile: profile, service: _service),
    );
    if (updated == null || !mounted) return;
    setState(() => _profile = updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Company profile updated successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _ProfileLoading();
    if (_error != null) {
      return _ProfileError(message: _error!, onRetry: _load);
    }
    final profile = _profile!;
    return RefreshIndicator(
      color: const Color(0xFF10B981),
      onRefresh: _load,
      child: ListView(
        key: const PageStorageKey('company-profile-view'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        children: [
          _CompanyHero(profile: profile),
          const SizedBox(height: 14),
          _DetailsCard(
            icon: Icons.business_outlined,
            title: 'Organization',
            children: [
              _DetailRow(
                icon: Icons.business_rounded,
                label: 'Company name',
                value: profile.companyName,
              ),
              _DetailRow(
                icon: Icons.category_outlined,
                label: 'Industry',
                value: profile.industry,
              ),
              _DetailRow(
                icon: Icons.groups_outlined,
                label: 'Company size',
                value: profile.companySize,
              ),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Founded',
                value: profile.foundedYear,
                last: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DetailsCard(
            icon: Icons.badge_outlined,
            title: 'Contact & Location',
            children: [
              _DetailRow(
                icon: Icons.person_outline_rounded,
                label: 'Representative',
                value: profile.adminName,
              ),
              _DetailRow(
                icon: Icons.mail_outline_rounded,
                label: 'Contact email',
                value: profile.contactEmail,
              ),
              _DetailRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: profile.phone,
              ),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'Headquarters',
                value: profile.location,
                last: true,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DetailsCard(
            icon: Icons.public_rounded,
            title: 'Digital Presence',
            children: [
              _DetailRow(
                icon: Icons.language_rounded,
                label: 'Website',
                value: profile.website,
              ),
              _DetailRow(
                icon: Icons.link_rounded,
                label: 'LinkedIn',
                value: profile.linkedinUrl,
              ),
              _DetailRow(
                icon: Icons.alternate_email_rounded,
                label: 'X / Twitter',
                value: profile.twitterUrl,
              ),
              _DetailRow(
                icon: Icons.code_rounded,
                label: 'GitHub',
                value: profile.githubUrl,
                last: true,
              ),
            ],
          ),
          if (profile.about.isNotEmpty) ...[
            const SizedBox(height: 14),
            _AboutCard(text: profile.about),
          ],
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _openEditor,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Company Profile'),
          ),
        ],
      ),
    );
  }
}

class _CompanyProfileEditor extends StatefulWidget {
  const _CompanyProfileEditor({required this.profile, required this.service});
  final CompanyProfile profile;
  final CompanyAccountService service;

  @override
  State<_CompanyProfileEditor> createState() => _CompanyProfileEditorState();
}

class _CompanyProfileEditorState extends State<_CompanyProfileEditor> {
  final _key = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _fields;
  late String _industry;
  late String _companySize;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _fields = {
      'companyName': TextEditingController(text: profile.companyName),
      'adminName': TextEditingController(text: profile.adminName),
      'contactEmail': TextEditingController(text: profile.contactEmail),
      'phone': TextEditingController(text: profile.phone),
      'foundedYear': TextEditingController(text: profile.foundedYear),
      'logoUrl': TextEditingController(text: profile.logoUrl),
      'website': TextEditingController(text: profile.website),
      'linkedinUrl': TextEditingController(text: profile.linkedinUrl),
      'twitterUrl': TextEditingController(text: profile.twitterUrl),
      'githubUrl': TextEditingController(text: profile.githubUrl),
      'location': TextEditingController(text: profile.location),
      'about': TextEditingController(text: profile.about),
    };
    _industry = profile.industry;
    _companySize = profile.companySize;
  }

  @override
  void dispose() {
    for (final controller in _fields.values) {
      controller.dispose();
    }
    super.dispose();
  }

  String _text(String key) => _fields[key]!.text.trim();

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final updated = await widget.service.updateProfile(
        CompanyProfile(
          companyName: _text('companyName'),
          adminName: _text('adminName'),
          contactEmail: _text('contactEmail'),
          phone: _text('phone'),
          companySize: _companySize,
          foundedYear: _text('foundedYear'),
          logoUrl: _text('logoUrl'),
          website: _text('website'),
          linkedinUrl: _text('linkedinUrl'),
          twitterUrl: _text('twitterUrl'),
          githubUrl: _text('githubUrl'),
          location: _text('location'),
          industry: _industry,
          about: _text('about'),
        ),
      );
      if (mounted) Navigator.pop(context, updated);
    } on CompanyAccountException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => HrSheet(
    title: 'Edit Company Profile',
    busy: _saving,
    footer: HrSaveButton(
      label: 'Save Changes',
      busy: _saving,
      onPressed: _save,
    ),
    body: Form(
      key: _key,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              _InlineError(_error!),
              const SizedBox(height: 14),
            ],
            const _FormSectionTitle('Organization'),
            _field(
              'companyName',
              'Company name',
              Icons.business_rounded,
              required: true,
            ),
            _dropdown(
              'Industry / sector',
              _industry,
              _industries,
              (value) => setState(() => _industry = value ?? ''),
            ),
            _dropdown(
              'Company size',
              _companySize,
              _companySizes,
              (value) => setState(() => _companySize = value ?? ''),
            ),
            _field(
              'foundedYear',
              'Founded year',
              Icons.calendar_today_outlined,
              keyboard: TextInputType.number,
            ),
            _field(
              'location',
              'Headquarters location',
              Icons.location_on_outlined,
            ),
            const _FormSectionTitle('Account representative'),
            _field(
              'adminName',
              'Administrator / representative',
              Icons.person_outline_rounded,
              required: true,
            ),
            _field(
              'contactEmail',
              'Official contact email',
              Icons.mail_outline_rounded,
              required: true,
              email: true,
              keyboard: TextInputType.emailAddress,
            ),
            _field(
              'phone',
              'Direct phone number',
              Icons.phone_outlined,
              keyboard: TextInputType.phone,
            ),
            const _FormSectionTitle('Digital presence'),
            _field(
              'logoUrl',
              'Company logo URL',
              Icons.image_outlined,
              keyboard: TextInputType.url,
            ),
            _field(
              'website',
              'Company website',
              Icons.language_rounded,
              keyboard: TextInputType.url,
            ),
            _field(
              'linkedinUrl',
              'LinkedIn URL',
              Icons.link_rounded,
              keyboard: TextInputType.url,
            ),
            _field(
              'twitterUrl',
              'X / Twitter URL',
              Icons.alternate_email_rounded,
              keyboard: TextInputType.url,
            ),
            _field(
              'githubUrl',
              'GitHub URL',
              Icons.code_rounded,
              keyboard: TextInputType.url,
            ),
            _field(
              'about',
              'About the company',
              Icons.article_outlined,
              lines: 5,
            ),
          ],
        ),
      ),
    ),
  );

  Widget _field(
    String key,
    String label,
    IconData icon, {
    bool required = false,
    bool email = false,
    int lines = 1,
    TextInputType? keyboard,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: _fields[key],
      maxLines: lines,
      keyboardType: keyboard,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (required && text.isEmpty) return 'This field is required';
        if (email &&
            text.isNotEmpty &&
            !RegExp(r'^\S+@\S+\.\S+$').hasMatch(text)) {
          return 'Enter a valid email address';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: lines > 1,
        prefixIcon: Icon(icon),
      ),
    ),
  );

  Widget _dropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String?> onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: DropdownButtonFormField<String>(
      key: ValueKey('$label$value'),
      initialValue: value.isEmpty ? null : value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
      ),
      items: {...values, if (value.isNotEmpty) value}
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    ),
  );
}

class _CompanyHero extends StatelessWidget {
  const _CompanyHero({required this.profile});
  final CompanyProfile profile;
  @override
  Widget build(BuildContext context) {
    final initials = (profile.companyName.isEmpty ? 'CO' : profile.companyName)
        .split(' ')
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();
    return Card(
      elevation: 2,
      shadowColor: const Color(0x160F172A),
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: const Color(0xFFD1FAE5),
              foregroundImage: profile.logoUrl.isEmpty
                  ? null
                  : NetworkImage(profile.logoUrl),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Color(0xFF047857),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          profile.companyName.isEmpty
                              ? 'Company Profile'
                              : profile.companyName,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF10B981),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.industry.isEmpty
                        ? 'Industry not specified'
                        : profile.industry,
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 11,
                    ),
                  ),
                  if (profile.location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      profile.location,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.icon,
    required this.title,
    required this.children,
  });
  final IconData icon;
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => HrCard(
    padding: EdgeInsets.zero,
    child: ExpansionTile(
      key: PageStorageKey('company-profile-$title'),
      initiallyExpanded: true,
      leading: Icon(icon, color: hrEmerald),
      title: Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: children,
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.last = false,
  });
  final IconData icon;
  final String label, value;
  final bool last;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 11),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 18),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value.isEmpty ? 'Not provided' : value,
                style: TextStyle(
                  color: value.isEmpty
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontStyle: value.isEmpty
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 1.5,
    shadowColor: const Color(0x120F172A),
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(17),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.article_outlined, color: Color(0xFF059669), size: 20),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'About the Company',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    ),
  );
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 5, bottom: 12),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 17,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
}

class _InlineError extends StatelessWidget {
  const _InlineError(this.message);
  final String message;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      message,
      style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 11),
    ),
  );
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFDC2626),
            size: 36,
          ),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    ),
  );
}
