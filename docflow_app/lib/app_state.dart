import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'models/doctor.dart';
import 'services/auth_service.dart';
import 'services/cloud_sync_service.dart';
import 'services/database_service.dart';

/// Global application state manager for authentication and data
class AppState extends ChangeNotifier {
  final AuthService _authService;
  final DatabaseService _databaseService;
  final SharedPreferences _prefs;

  /// Current authenticated doctor (null if not logged in)
  Doctor? _currentDoctor;

  /// Cloud sync service
  late final CloudSyncService _cloudSyncService;

  /// Current authentication status
  bool _isAuthenticated = false;
  bool _isInitialized = false;

  /// Authentication messages/errors
  String? _authError;

  AppState({
    required AuthService authService,
    required DatabaseService databaseService,
    required SharedPreferences prefs,
  })  : _authService = authService,
        _databaseService = databaseService,
        _prefs = prefs {
    _cloudSyncService = CloudSyncService(databaseService: _databaseService);
  }

  // Getters
  Doctor? get currentDoctor => _currentDoctor;
  DatabaseService get databaseService => _databaseService;
  AuthService get authService => _authService;
  CloudSyncService get cloudSyncService => _cloudSyncService;
  bool get isAuthenticated => _isAuthenticated;
  bool get isInitialized => _isInitialized;
  String? get authError => _authError;
  bool get isLockedOut => _authService.isLockedOut;
  int get lockoutRemainingSeconds => _authService.lockoutRemainingSeconds;
  int get failedAttempts => _authService.failedAttempts;

  /// Initialize app state - check for existing authentication
  Future<void> initialize() async {
    try {
      await _authService.initialize();

      // Check if doctor exists in database. We keep the profile loaded so the
      // PIN screen can still gate access on app launch.
      final savedDoctorPhone = _prefs.getString('current_doctor_phone');
      if (savedDoctorPhone != null && !_authService.isLockedOut) {
        final doctor = await _databaseService.getDoctor(savedDoctorPhone);
        if (doctor != null) {
          _currentDoctor = doctor;
          _isAuthenticated = false;
        }
      }
    } catch (e) {
      _authError = 'Failed to initialize: $e';
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Register a new doctor with PIN
  Future<bool> registerDoctor({
    required String fullName,
    required String phoneNumber,
    required String specialty,
    required String pin,
  }) async {
    try {
      _authError = null;

      // Register PIN with AuthService
      final registered = await _authService.registerDoctor(pin);
      if (!registered) {
        _authError = 'Doctor already registered on this device';
        notifyListeners();
        return false;
      }

      // Create and save doctor to database
      final doctor = Doctor(
        id: const Uuid().v4(),
        fullName: fullName,
        phoneNumber: phoneNumber,
        specialty: specialty,
        pinHash: AuthService.hashPin(pin),
        createdAt: DateTime.now(),
      );

      await _databaseService.saveDoctor(doctor);
      _currentDoctor = doctor;
      _isAuthenticated = true;

      // Save phone for future auto-login
      await _prefs.setString('current_doctor_phone', phoneNumber);
      await _prefs.setBool('onboarding_complete', true);

      notifyListeners();
      return true;
    } catch (e) {
      _authError = 'Registration failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Login with PIN
  Future<bool> login(String pin) async {
    try {
      _authError = null;

      // Verify PIN
      final result = await _authService.login(pin);

      if (result == 'success') {
        // Get saved doctor phone
        final doctorPhone = _prefs.getString('current_doctor_phone');
        if (doctorPhone != null) {
          final doctor = await _databaseService.getDoctor(doctorPhone);
          if (doctor != null) {
            _currentDoctor = doctor;
            _isAuthenticated = true;
            notifyListeners();
            return true;
          }
        }
        _authError = 'Doctor not found';
        notifyListeners();
        return false;
      } else if (result == 'locked_out') {
        _authError = 'Too many failed attempts. Try again in ${_authService.lockoutRemainingSeconds}s';
        notifyListeners();
        return false;
      } else if (result == 'invalid_pin') {
        _authError = 'Invalid PIN (${3 - _authService.failedAttempts} attempts remaining)';
        notifyListeners();
        return false;
      } else if (result == 'not_registered') {
        _authError = 'No PIN registered. Please register first.';
        notifyListeners();
        return false;
      }

      _authError = 'Login failed';
      notifyListeners();
      return false;
    } catch (e) {
      _authError = 'Login error: $e';
      notifyListeners();
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      _currentDoctor = null;
      _isAuthenticated = false;
      _authError = null;
      await _prefs.remove('current_doctor_phone');
      notifyListeners();
    } catch (e) {
      _authError = 'Logout failed: $e';
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _authError = null;
    notifyListeners();
  }
}

/// InheritedWidget for accessing AppState
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    required AppState notifier,
    required Widget child,
    Key? key,
  }) : super(notifier: notifier, child: child, key: key);

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateProvider>()!.notifier!;
  }

  static AppState? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateProvider>()?.notifier;
  }
}
