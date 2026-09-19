import 'package:flutter/material.dart';

import 'screens/candidate/candidate_main_scaffold.dart';

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
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: emerald,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
      ),
      home: const CandidateMainScaffold(),
    );
  }
}
