import 'package:flutter/material.dart';

import '../../services/company_account_service.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  Future<void> _openPasswordEditor(BuildContext context) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PasswordEditor(),
    );
    if (changed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    key: const PageStorageKey('security-settings-view'),
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
    children: [
      Card(
        elevation: 2,
        shadowColor: const Color(0x160F172A),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFA7F3D0)),
        ),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              _SecurityIcon(icon: Icons.verified_user_outlined, filled: true),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Protected',
                      style: TextStyle(
                        color: Color(0xFF065F46),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your company account uses secure password authentication.',
                      style: TextStyle(
                        color: Color(0xFF047857),
                        fontSize: 11,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      const _SecurityCard(
        title: 'Sign-in Security',
        icon: Icons.lock_outline_rounded,
        children: [
          _SecurityRow(
            icon: Icons.password_rounded,
            label: 'Password',
            value: '••••••••••••',
            status: 'Active',
          ),
          _SecurityRow(
            icon: Icons.update_rounded,
            label: 'Password last changed',
            value: 'Not provided by server',
          ),
          _SecurityRow(
            icon: Icons.phonelink_lock_outlined,
            label: 'Session storage',
            value: 'Encrypted device storage',
            status: 'Secure',
            last: true,
          ),
        ],
      ),
      const SizedBox(height: 14),
      const _SecurityCard(
        title: 'Security Guidance',
        icon: Icons.health_and_safety_outlined,
        children: [
          _GuidanceRow(
            icon: Icons.check_circle_outline_rounded,
            text: 'Use a unique password with at least 6 characters.',
          ),
          _GuidanceRow(
            icon: Icons.check_circle_outline_rounded,
            text: 'Never share company credentials with candidates.',
          ),
          _GuidanceRow(
            icon: Icons.check_circle_outline_rounded,
            text: 'Sign out on shared or unmanaged devices.',
            last: true,
          ),
        ],
      ),
      const SizedBox(height: 18),
      ElevatedButton.icon(
        onPressed: () => _openPasswordEditor(context),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Change Password'),
      ),
    ],
  );
}

class _PasswordEditor extends StatefulWidget {
  const _PasswordEditor();
  @override
  State<_PasswordEditor> createState() => _PasswordEditorState();
}

class _PasswordEditorState extends State<_PasswordEditor> {
  final _key = GlobalKey<FormState>();
  final _service = CompanyAccountService();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _showCurrent = false;
  bool _showPassword = false;
  bool _showConfirmation = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _service.changePassword(
        currentPassword: _current.text,
        newPassword: _password.text,
        confirmNewPassword: _confirmation.text,
      );
      if (mounted) Navigator.pop(context, true);
    } on CompanyAccountException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => FractionallySizedBox(
    heightFactor: .76,
    child: Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 14),
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Change Password',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Confirm your identity and choose a new password',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Form(
              key: _key,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (_error != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Color(0xFFB91C1C),
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    _passwordField(
                      controller: _current,
                      label: 'Current password',
                      visible: _showCurrent,
                      toggle: () =>
                          setState(() => _showCurrent = !_showCurrent),
                    ),
                    _passwordField(
                      controller: _password,
                      label: 'New password',
                      visible: _showPassword,
                      toggle: () =>
                          setState(() => _showPassword = !_showPassword),
                      isNew: true,
                    ),
                    _passwordField(
                      controller: _confirmation,
                      label: 'Confirm new password',
                      visible: _showConfirmation,
                      toggle: () => setState(
                        () => _showConfirmation = !_showConfirmation,
                      ),
                      confirmation: true,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _Requirement(
                            text: 'Minimum 6 characters',
                            valid: _password.text.length >= 6,
                          ),
                          const SizedBox(height: 8),
                          _Requirement(
                            text: 'New passwords match',
                            valid:
                                _confirmation.text.isNotEmpty &&
                                _password.text == _confirmation.text,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              boxShadow: [
                BoxShadow(
                  color: Color(0x100F172A),
                  blurRadius: 12,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shield_outlined),
                label: Text(_saving ? 'Updating...' : 'Save New Password'),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback toggle,
    bool isNew = false,
    bool confirmation = false,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      obscureText: !visible,
      onChanged: (_) => setState(() {}),
      validator: (value) {
        if (value == null || value.isEmpty) return 'This field is required';
        if (isNew && value.length < 6) return 'Use at least 6 characters';
        if (confirmation && value != _password.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: visible ? 'Hide password' : 'Show password',
          onPressed: toggle,
          icon: Icon(
            visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
        ),
      ),
    ),
  );
}

class _SecurityCard extends StatelessWidget {
  const _SecurityCard({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _SecurityIcon(icon: icon),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    ),
  );
}

class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.icon,
    required this.label,
    required this.value,
    this.status,
    this.last = false,
  });
  final IconData icon;
  final String label, value;
  final String? status;
  final bool last;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      border: last
          ? null
          : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
    ),
    child: Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 19),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (status != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status!,
              style: const TextStyle(
                color: Color(0xFF047857),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    ),
  );
}

class _GuidanceRow extends StatelessWidget {
  const _GuidanceRow({
    required this.icon,
    required this.text,
    this.last = false,
  });
  final IconData icon;
  final String text;
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
      children: [
        Icon(icon, color: const Color(0xFF10B981), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.text, required this.valid});
  final String text;
  final bool valid;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        valid
            ? Icons.check_circle_rounded
            : Icons.radio_button_unchecked_rounded,
        size: 17,
        color: valid ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(
          color: valid ? const Color(0xFF047857) : const Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _SecurityIcon extends StatelessWidget {
  const _SecurityIcon({required this.icon, this.filled = false});
  final IconData icon;
  final bool filled;
  @override
  Widget build(BuildContext context) => Container(
    width: 42,
    height: 42,
    decoration: BoxDecoration(
      color: filled ? const Color(0xFF10B981) : const Color(0xFFECFDF5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(
      icon,
      color: filled ? Colors.white : const Color(0xFF059669),
      size: 21,
    ),
  );
}
