import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'app_state.dart';
import 'services/auth_service.dart';
import 'services/calculator_loader.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase can be enabled later without blocking the offline app.
  }

  // Initialize services
  final prefs = await SharedPreferences.getInstance();
  final databaseService = DatabaseService();
  final authService = AuthService(prefs);

  // Create app state
  final appState = AppState(
    authService: authService,
    databaseService: databaseService,
    prefs: prefs,
  );

  // Initialize calculator definitions
  await CalculatorLoader.instance.load();

  // Initialize app state (check for existing auth)
  await appState.initialize();

  runApp(
    AppStateProvider(
      notifier: appState,
      child: const DocFlowApp(),
    ),
  );
}

