import 'package:flutter/material.dart';

import '../../components/skill_hub_loading_indicator.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Center(child: SkillHubLoadingIndicator(message: message)),
    );
  }
}
