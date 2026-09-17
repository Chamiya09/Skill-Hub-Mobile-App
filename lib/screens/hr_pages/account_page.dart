import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../login_screen.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();
    if (!context.mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
  }

  @override
  Widget build(BuildContext context) => ListView(
    key: const PageStorageKey('account-page'),
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        'Company account',
        style: TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 24,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 6),
      const Text(
        'Manage your enterprise profile and security.',
        style: TextStyle(color: Color(0xFF64748B)),
      ),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Color(0xFFD1FAE5),
              child: Icon(
                Icons.business_rounded,
                color: Color(0xFF059669),
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company Profile',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Enterprise HR account',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const _AccountTile(
        Icons.business_outlined,
        'Company details',
        'Name, industry and contact information',
      ),
      const SizedBox(height: 10),
      const _AccountTile(
        Icons.lock_outline_rounded,
        'Security',
        'Update your company password',
      ),
      const SizedBox(height: 28),
      OutlinedButton.icon(
        onPressed: () => _logout(context),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFDC2626),
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: Color(0xFFFECACA)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ],
  );
}

class _AccountTile extends StatelessWidget {
  const _AccountTile(this.icon, this.title, this.subtitle);
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF059669)),
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
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    ),
  );
}
