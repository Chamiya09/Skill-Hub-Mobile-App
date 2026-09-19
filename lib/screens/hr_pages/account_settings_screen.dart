import 'package:flutter/material.dart';

import '../../models/company_profile.dart';
import '../../widgets/hr_mobile_ui.dart';
import '../../services/auth_service.dart';
import '../../services/company_account_service.dart';
import '../login_screen.dart';
import 'company_profile_screen.dart';
import 'security_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _accountService = CompanyAccountService();
  CompanyProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _accountService.getProfile();
      if (mounted) setState(() => _profile = profile);
    } on CompanyAccountException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openPage({required String title, required Widget child}) async {
    await showHrSheet<void>(
      context,
      builder: (context) => HrSheet(
        title: title,
        body: child,
        footer: HrSaveButton(
          label: 'Done',
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );

    if (title == 'Company Profile' && mounted) {
      await _loadProfile();
    }
  }

  Future<void> _signOut() async {
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
  Widget build(BuildContext context) => RefreshIndicator(
    color: const Color(0xFF10B981),
    onRefresh: _loadProfile,
    child: ListView(
      key: const PageStorageKey('account-settings-hub'),
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        _AccountHeader(profile: _profile, loading: _loading),
        if (_error != null) ...[
          const SizedBox(height: 14),
          _ErrorBanner(message: _error!, onRetry: _loadProfile),
        ],
        const SizedBox(height: 26),
        const Text(
          'ACCOUNT & SETTINGS',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        _NavigationCard(
          icon: Icons.business_outlined,
          title: 'Company Profile',
          subtitle: 'View and manage organization, contact, and public details',
          onTap: () => _openPage(
            title: 'Company Profile',
            child: const CompanyProfileScreen(),
          ),
        ),
        const SizedBox(height: 12),
        _NavigationCard(
          icon: Icons.shield_outlined,
          title: 'Security & Login',
          subtitle: 'Review account protection and update your password',
          onTap: () => _openPage(
            title: 'Security & Login',
            child: const SecurityScreen(),
          ),
        ),
        const SizedBox(height: 34),
        const Divider(color: Color(0xFFE2E8F0)),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _signOut,
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Sign Out'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFDC2626),
            backgroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            side: const BorderSide(color: Color(0xFFFECACA)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    ),
  );
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.profile, required this.loading});

  final CompanyProfile? profile;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final companyName = profile?.companyName.trim() ?? '';
    final email = profile?.contactEmail.trim() ?? '';
    final logoUrl = profile?.logoUrl.trim() ?? '';
    final initials = (companyName.isEmpty ? 'CO' : companyName)
        .split(' ')
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFECFDF5)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA7F3D0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x120F172A),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: loading
          ? const SizedBox(
              height: 74,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF10B981),
                  strokeWidth: 2.5,
                ),
              ),
            )
          : Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1FAE5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x18047857),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                    image: logoUrl.isEmpty
                        ? null
                        : DecorationImage(
                            image: NetworkImage(logoUrl),
                            fit: BoxFit.cover,
                          ),
                  ),
                  alignment: Alignment.center,
                  child: logoUrl.isEmpty
                      ? Text(
                          initials,
                          style: const TextStyle(
                            color: Color(0xFF047857),
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              companyName.isEmpty
                                  ? 'Company Account'
                                  : companyName,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: Color(0xFF10B981),
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.mail_outline_rounded,
                            color: Color(0xFF64748B),
                            size: 15,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              email.isEmpty ? 'Email not available' : email,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'ENTERPRISE HR ACCOUNT',
                          style: TextStyle(
                            color: Color(0xFF047857),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .5,
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
}

class _NavigationCard extends StatelessWidget {
  const _NavigationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    color: Colors.white,
    elevation: 2,
    shadowColor: const Color(0x140F172A),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF059669), size: 23),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFEF2F2),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFECACA)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626)),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 11),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
      ],
    ),
  );
}
