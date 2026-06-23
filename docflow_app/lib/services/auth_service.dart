import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

/// Service for managing doctor authentication via PIN and lockout logic.
class AuthService {
  static const String _pinHashKey = 'doctor_pin_hash';
  static const String _lockoutKey = 'auth_lockout_time';
  static const String _attemptsKey = 'auth_failed_attempts';
  static const int _maxAttempts = 3;
  static const int _lockoutDurationSeconds = 30;

  final SharedPreferences _prefs;

  /// Timer for automatic lockout expiry
  Timer? _lockoutTimer;

  /// Current lockout state (cached for performance)
  bool _isLockedOut = false;

  AuthService(this._prefs);

  /// Check if the doctor is currently locked out due to failed attempts.
  /// Automatically clears lockout if duration has expired.
  bool get isLockedOut => _isLockedOut;

  /// Get the number of failed attempts since the last successful login.
  int get failedAttempts => _prefs.getInt(_attemptsKey) ?? 0;

  /// Get remaining lockout time in seconds (0 if not locked out).
  int get lockoutRemainingSeconds {
    if (!_isLockedOut) return 0;
    final lockoutTime = _prefs.getInt(_lockoutKey);
    if (lockoutTime == null) return 0;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final remaining = ((lockoutTime - now) / 1000).ceil();
    return remaining > 0 ? remaining : 0;
  }

  /// Initialize auth service - checks for existing lockout and restores state.
  /// Should be called once during app startup.
  Future<void> initialize() async {
    await _checkAndClearExpiredLockout();
  }

  /// Check if a lockout has expired and clear it.
  Future<void> _checkAndClearExpiredLockout() async {
    final lockoutTime = _prefs.getInt(_lockoutKey);
    if (lockoutTime == null) {
      _isLockedOut = false;
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= lockoutTime) {
      await _clearLockout();
      _isLockedOut = false;
    } else {
      _isLockedOut = true;
      _scheduleLockoutExpiry(lockoutTime - now);
    }
  }

  /// Schedule automatic lockout expiry
  void _scheduleLockoutExpiry(int millisRemaining) {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer(Duration(milliseconds: millisRemaining), () async {
      await _clearLockout();
      _isLockedOut = false;
    });
  }

  /// Clear lockout state (called on expiry or successful login)
  Future<void> _clearLockout() async {
    await _prefs.remove(_lockoutKey);
    await _prefs.setInt(_attemptsKey, 0);
  }

  /// Hash a PIN using SHA-256 for secure storage.
  /// Format: "sha256=<hash>" for versioning compatibility.
  static String hashPin(String pin) {
    final hash = sha256.convert(pin.codeUnits);
    return 'sha256=${hash.toString()}';
  }

  /// Register a new doctor with their PIN.
  /// Returns true if registration succeeds, false if already registered.
  Future<bool> registerDoctor(String pin) async {
    final existingHash = _prefs.getString(_pinHashKey);
    if (existingHash != null) {
      return false; // Already registered
    }

    final pinHash = hashPin(pin);
    await _prefs.setString(_pinHashKey, pinHash);
    await _clearLockout();
    return true;
  }

  /// Attempt to log in with a PIN.
  /// Returns:
  ///   - 'success' if PIN is correct
  ///   - 'locked_out' if too many failed attempts
  ///   - 'invalid_pin' if PIN is incorrect
  ///   - 'not_registered' if no PIN hash exists
  Future<String> login(String pin) async {
    // Check lockout status
    if (_isLockedOut) {
      return 'locked_out';
    }

    // Get stored PIN hash
    final storedHash = _prefs.getString(_pinHashKey);
    if (storedHash == null) {
      return 'not_registered';
    }

    // Verify PIN
    final providedHash = hashPin(pin);
    if (providedHash == storedHash) {
      // Successful login - clear lockout and attempts
      await _clearLockout();
      return 'success';
    }

    // Failed attempt - increment counter and check for lockout
    int attempts = failedAttempts + 1;
    await _prefs.setInt(_attemptsKey, attempts);

    if (attempts >= _maxAttempts) {
      // Trigger lockout
      final lockoutTime =
          DateTime.now().millisecondsSinceEpoch +
          (_lockoutDurationSeconds * 1000);
      await _prefs.setInt(_lockoutKey, lockoutTime);
      _isLockedOut = true;
      _scheduleLockoutExpiry(_lockoutDurationSeconds * 1000);
      return 'locked_out';
    }

    return 'invalid_pin';
  }

  /// Reset authentication state (used for logout or admin reset).
  Future<void> reset() async {
    await _prefs.remove(_pinHashKey);
    await _clearLockout();
    _lockoutTimer?.cancel();
    _isLockedOut = false;
  }

  /// Check if a doctor is registered.
  bool get isRegistered => _prefs.getString(_pinHashKey) != null;

  /// Dispose resources (call this on app shutdown).
  void dispose() {
    _lockoutTimer?.cancel();
  }
}
