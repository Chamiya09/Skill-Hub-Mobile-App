import 'package:flutter/material.dart';

import '../../models/job_vacancy.dart';
import '../../services/jobs_service.dart';

class JobFormPage extends StatefulWidget {
  const JobFormPage({super.key, this.job});
  final JobVacancy? job;
  @override
  State<JobFormPage> createState() => _JobFormPageState();
}

class _JobFormPageState extends State<JobFormPage> {
  final _key = GlobalKey<FormState>();
  final _service = JobsService();
  late final Map<String, TextEditingController> _fields;
  late String _type, _level, _status;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final j = widget.job;
    _fields = {
      'title': TextEditingController(text: j?.title),
      'department': TextEditingController(text: j?.department),
      'location': TextEditingController(text: j?.location),
      'salary': TextEditingController(text: j?.salaryRange),
      'description': TextEditingController(text: j?.description),
      'offer': TextEditingController(text: j?.whatWeOffer),
    };
    _type = j?.employmentType ?? 'Full-time';
    _level = j?.experienceLevel ?? 'Mid Level';
    _status = j?.status ?? 'Active';
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Required' : null;

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    final input = JobInput(
      title: _fields['title']!.text.trim(),
      department: _fields['department']!.text.trim(),
      location: _fields['location']!.text.trim(),
      employmentType: _type,
      experienceLevel: _level,
      status: _status,
      salaryRange: _fields['salary']!.text.trim(),
      description: _fields['description']!.text.trim(),
      whatWeOffer: _fields['offer']!.text.trim(),
    );
    try {
      final result = widget.job == null
          ? await _service.createJob(input)
          : await _service.updateJob(widget.job!.id, input);
      if (mounted) {
        Navigator.pop(context, result);
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
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(
        widget.job == null ? 'Create New Job' : 'Edit Job Vacancy',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
    body: Form(
      key: _key,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _FormHeading(
            'Role information',
            'Define the position and its team.',
          ),
          const SizedBox(height: 16),
          _field('title', 'Job title', Icons.work_outline_rounded),
          const SizedBox(height: 14),
          _field('department', 'Department', Icons.business_outlined),
          const SizedBox(height: 14),
          _field('location', 'Location', Icons.location_on_outlined),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Employment type'),
            items: [
              'Full-time',
              'Part-time',
              'Contract',
              'Remote',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _level,
            decoration: const InputDecoration(labelText: 'Experience level'),
            items: [
              'Entry Level',
              'Mid Level',
              'Senior Level (5+ Yrs)',
              'Lead',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _level = v!),
          ),
          const SizedBox(height: 14),
          _field(
            'salary',
            'Salary range (optional)',
            Icons.payments_outlined,
            required: false,
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: [
              'Active',
              'Draft',
              'Closed',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
          const SizedBox(height: 26),
          const _FormHeading(
            'Job content',
            'Use one responsibility or benefit per line for bullet styling.',
          ),
          const SizedBox(height: 16),
          _field(
            'description',
            'Job description',
            Icons.article_outlined,
            lines: 8,
          ),
          const SizedBox(height: 14),
          _field(
            'offer',
            'What we offer',
            Icons.volunteer_activism_outlined,
            lines: 6,
            required: false,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.4,
                    ),
                  )
                : Text(widget.job == null ? 'Publish Job' : 'Save Changes'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );

  Widget _field(
    String key,
    String label,
    IconData icon, {
    int lines = 1,
    bool required = true,
  }) => TextFormField(
    controller: _fields[key],
    maxLines: lines,
    validator: required ? _required : null,
    decoration: InputDecoration(
      labelText: label,
      alignLabelWithHint: lines > 1,
      prefixIcon: Icon(icon),
    ),
  );
}

class _FormHeading extends StatelessWidget {
  const _FormHeading(this.title, this.subtitle);
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        subtitle,
        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
      ),
    ],
  );
}
