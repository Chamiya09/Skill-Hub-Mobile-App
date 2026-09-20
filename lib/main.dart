import 'package:flutter/material.dart';

import 'screens/auth/auth_gate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const emerald = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skill Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // InkSparkle uses a runtime fragment shader that is unreliable on
        // some Android emulators and older GPU drivers. InkRipple keeps the
        // same Material interaction without requiring shader compilation.
        splashFactory: InkRipple.splashFactory,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: emerald,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
      ),
      home: const AuthGate(),
    );
  }
}
