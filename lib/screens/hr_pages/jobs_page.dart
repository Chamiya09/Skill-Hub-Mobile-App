import 'package:flutter/material.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({super.key});

  @override
  Widget build(BuildContext context) => ListView(
    key: const PageStorageKey('jobs-page'),
    padding: const EdgeInsets.all(20),
    children: [
      Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job vacancies',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Manage open and closed positions.',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded, size: 19),
            label: const Text('New'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
      const SizedBox(height: 22),
      TextField(
        decoration: InputDecoration(
          hintText: 'Search jobs',
          prefixIcon: const Icon(Icons.search_rounded),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      const SizedBox(height: 22),
      const _EmptyState(),
    ],
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    ),
    child: const Column(
      children: [
        CircleAvatar(
          radius: 31,
          backgroundColor: Color(0xFFD1FAE5),
          child: Icon(
            Icons.work_outline_rounded,
            color: Color(0xFF059669),
            size: 30,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'No jobs to show',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Your company job vacancies will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF64748B), height: 1.4),
        ),
      ],
    ),
  );
}
