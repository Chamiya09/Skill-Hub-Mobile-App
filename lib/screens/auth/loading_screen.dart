import 'package:flutter/material.dart';

import '../../components/skill_hub_loading_indicator.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(child: SkillHubLoadingIndicator()),
    );
  }
}
