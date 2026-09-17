import 'package:flutter/material.dart';
import '../main.dart';
import '../services/auth_service.dart';
import 'hr_dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); static const routeName = '/'; @override State<SplashScreen> createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> {
  @override void initState() { super.initState(); _initialize(); }
  Future<void> _initialize() async {
    final result = await Future.wait([Future.delayed(const Duration(seconds: 2)), AuthService().hasValidToken()]);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, result[1] as bool ? HrDashboardScreen.routeName : LoginScreen.routeName);
  }
  @override Widget build(BuildContext context) => const Scaffold(backgroundColor: Colors.white, body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [DecoratedBox(decoration: BoxDecoration(color: SkillHubApp.emerald, shape: BoxShape.circle), child: Padding(padding: EdgeInsets.all(22), child: Icon(Icons.hub_rounded, size: 54, color: Colors.white))), SizedBox(height: 22), Text('Skill Hub', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)), SizedBox(height: 8), Text('Enterprise hiring, simplified', style: TextStyle(color: Color(0xFF64748B))), SizedBox(height: 36), CircularProgressIndicator(color: SkillHubApp.emerald, strokeWidth: 3)])));
}
