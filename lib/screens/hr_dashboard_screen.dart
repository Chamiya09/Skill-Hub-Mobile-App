import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
class HrDashboardScreen extends StatelessWidget {
  const HrDashboardScreen({super.key}); static const routeName = '/hr-dashboard';
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('HR Dashboard'), actions: [IconButton(tooltip: 'Logout', icon: const Icon(Icons.logout_rounded), onPressed: () async { await AuthService().logout(); if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (_) => false); })]), body: const Center(child: Text('Welcome to Skill Hub', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700))));
}
