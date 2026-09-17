import 'package:flutter/material.dart';

class ScreeningPipelinePage extends StatelessWidget {
  const ScreeningPipelinePage({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    key: const PageStorageKey('screening-pipeline-page'),
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        'AI Screening',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'Review candidates and move the best matches through your pipeline.',
        style: TextStyle(color: Color(0xFF64748B), height: 1.4),
      ),
      const SizedBox(height: 22),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF059669), Color(0xFF10B981)],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 34),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart candidate ranking',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Select a job to screen and rank its applicants.',
                    style: TextStyle(color: Color(0xFFE6FFFA), height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      const Text(
        'Hiring pipeline',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 14),
      const _PipelineStage('Applied', 'New candidates', Icons.inbox_outlined),
      const SizedBox(height: 10),
      const _PipelineStage(
        'AI Screened',
        'Scored by skills and experience',
        Icons.auto_awesome_outlined,
      ),
      const SizedBox(height: 10),
      const _PipelineStage(
        'Shortlisted',
        'Ready for the next step',
        Icons.star_outline_rounded,
      ),
    ],
  );
}

class _PipelineStage extends StatelessWidget {
  const _PipelineStage(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF059669)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
      ],
    ),
  );
}
