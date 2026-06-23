import 'package:flutter/material.dart';
import 'package:docflow_app/app_state.dart';
import 'package:docflow_app/screens/home_screen.dart';
import 'package:docflow_app/screens/pin_screen.dart';
import 'package:docflow_app/screens/onboarding_screen.dart';
import 'package:docflow_app/utils/constants.dart';

class DocFlowApp extends StatelessWidget {
  const DocFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocFlow',
      theme: AppConstants.themeData,
      home: const DocFlowHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Route to appropriate screen based on authentication status
class DocFlowHome extends StatelessWidget {
  const DocFlowHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Get app state
    final appState = AppStateProvider.maybeOf(context);

    // Still initializing
    if (appState == null || !appState.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // User authenticated - show main app
    if (appState.isAuthenticated && appState.currentDoctor != null) {
      return const HomeScreen();
    }

    // Doctor profile exists but is not unlocked yet
    if (appState.currentDoctor != null) {
      return const PinScreen();
    }

    // No doctor profile yet - show onboarding
    return const OnboardingScreen();
  }
}

