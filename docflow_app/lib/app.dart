import 'package:flutter/material.dart';
import 'package:docflow_app/screens/onboarding_screen.dart';
import 'package:docflow_app/utils/constants.dart';

class DocFlowApp extends StatelessWidget {
  const DocFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocFlow',
      theme: AppConstants.themeData,
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
