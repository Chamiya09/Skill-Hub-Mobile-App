import 'package:flutter/material.dart';

import '../../models/auth_session.dart';
import '../../services/auth_service.dart';
import '../candidate/candidate_main_scaffold.dart';
import 'candidate_login_screen.dart';
import 'loading_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService _authService = AuthService();
  AuthSession? _session;
  bool _restoring = true;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    AuthSession? session;
    try {
      session = await _authService.restoreSession();
    } finally {
      if (mounted) {
        setState(() {
          _session = session;
          _restoring = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (mounted) setState(() => _session = null);
  }

  @override
  void dispose() {
    _authService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_restoring) return const LoadingScreen();
    if (_session == null) {
      return CandidateLoginScreen(
        authService: _authService,
        onAuthenticated: (session) => setState(() => _session = session),
      );
    }
    return CandidateMainScaffold(user: _session!.user, onLogout: _logout);
  }
}
