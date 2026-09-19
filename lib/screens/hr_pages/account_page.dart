import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'company_profile_screen.dart';
import 'security_screen.dart';

enum _AccountTab { profile, security }

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  _AccountTab _tab = _AccountTab.profile;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
        title: const Text('Sign out?'),
        content: const Text(
          'You will need to sign in again to manage your company account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AuthService().logout();
    if (!mounted) return;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(LoginScreen.routeName, (_) => false);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Company Account',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'View and manage your company profile and security.',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: 'Sign out',
                  onPressed: _logout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SegmentedButton<_AccountTab>(
              segments: const [
                ButtonSegment(
                  value: _AccountTab.profile,
                  icon: Icon(Icons.business_outlined),
                  label: Text('Company Profile'),
                ),
                ButtonSegment(
                  value: _AccountTab.security,
                  icon: Icon(Icons.shield_outlined),
                  label: Text('Security'),
                ),
              ],
              selected: {_tab},
              showSelectedIcon: false,
              onSelectionChanged: (value) => setState(() => _tab = value.first),
            ),
          ],
        ),
      ),
      Expanded(
        child: IndexedStack(
          index: _tab.index,
          children: const [CompanyProfileScreen(), SecurityScreen()],
        ),
      ),
    ],
  );
}
