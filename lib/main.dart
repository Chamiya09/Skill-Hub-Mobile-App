import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/hr_dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SkillHubApp());
}

class SkillHubApp extends StatelessWidget {
  const SkillHubApp({super.key});
  static const emerald = Color(0xFF10B981);
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Skill Hub',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: emerald),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: GoogleFonts.interTextTheme(),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(emerald, 1.6),
        errorBorder: _border(Colors.redAccent),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emerald,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    ),
    initialRoute: SplashScreen.routeName,
    routes: {
      SplashScreen.routeName: (_) => const SplashScreen(),
      LoginScreen.routeName: (_) => const LoginScreen(),
      HrDashboardScreen.routeName: (_) => const HrDashboardScreen(),
    },
  );
  static OutlineInputBorder _border([
    Color color = const Color(0xFFE2E8F0),
    double width = 1,
  ]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color, width: width),
  );
}
