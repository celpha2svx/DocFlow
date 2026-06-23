import 'package:flutter_test/flutter_test.dart';
import 'package:docflow_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;
    late SharedPreferences prefs;

    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    setUp(() async {
      // Clear all preferences before each test
      await prefs.clear();
      authService = AuthService(prefs);
      await authService.initialize();
    });

    tearDown(() {
      authService.dispose();
    });

    group('Registration', () {
      test('New doctor can register with PIN', () async {
        expect(authService.isRegistered, false);
        final result = await authService.registerDoctor('1234');
        expect(result, true);
        expect(authService.isRegistered, true);
      });

      test('Cannot register twice', () async {
        await authService.registerDoctor('1234');
        final result = await authService.registerDoctor('5678');
        expect(result, false);
      });

      test('Registration clears any lockout', () async {
        await authService.registerDoctor('1234');
        // Simulate failed attempts and lockout
        await authService.login('wrong');
        await authService.login('wrong');
        await authService.login('wrong');
        expect(authService.isLockedOut, true);

        // Re-register should clear lockout
        await authService.reset();
        await authService.registerDoctor('5678');
        expect(authService.isLockedOut, false);
      });
    });

    group('Login Success', () {
      setUp(() async {
        await authService.registerDoctor('1234');
      });

      test('Correct PIN returns success', () async {
        final result = await authService.login('1234');
        expect(result, 'success');
      });

      test('Successful login clears failed attempts', () async {
        await authService.login('wrong');
        expect(authService.failedAttempts, 1);
        
        final result = await authService.login('1234');
        expect(result, 'success');
        expect(authService.failedAttempts, 0);
        expect(authService.isLockedOut, false);
      });

      test('Different valid PIN after registration still works', () async {
        await authService.reset();
        await authService.registerDoctor('9999');
        
        final result = await authService.login('9999');
        expect(result, 'success');
      });
    });

    group('Login Failure', () {
      setUp(() async {
        await authService.registerDoctor('1234');
      });

      test('Wrong PIN returns invalid_pin', () async {
        final result = await authService.login('5678');
        expect(result, 'invalid_pin');
      });

      test('Wrong PIN increments failed attempts', () async {
        expect(authService.failedAttempts, 0);
        
        await authService.login('wrong');
        expect(authService.failedAttempts, 1);
        
        await authService.login('wrong');
        expect(authService.failedAttempts, 2);
      });

      test('Third failed attempt triggers lockout', () async {
        expect(authService.isLockedOut, false);
        
        await authService.login('wrong');
        await authService.login('wrong');
        expect(authService.isLockedOut, false);
        
        await authService.login('wrong');
        expect(authService.isLockedOut, true);
        expect(authService.failedAttempts, 3);
      });

      test('Locked out prevents login attempts', () async {
        await authService.login('wrong');
        await authService.login('wrong');
        await authService.login('wrong');
        expect(authService.isLockedOut, true);
        
        // Even correct PIN fails during lockout
        final result = await authService.login('1234');
        expect(result, 'locked_out');
      });

      test('Unregistered doctor cannot login', () async {
        await authService.reset();
        final result = await authService.login('1234');
        expect(result, 'not_registered');
      });
    });

    group('Lockout Duration', () {
      setUp(() async {
        await authService.registerDoctor('1234');
      });

      test('Lockout remaining seconds is positive after lockout', () async {
        await authService.login('wrong');
        await authService.login('wrong');
        await authService.login('wrong');
        
        expect(authService.isLockedOut, true);
        expect(authService.lockoutRemainingSeconds, greaterThan(0));
        expect(authService.lockoutRemainingSeconds, lessThanOrEqualTo(30));
      });

      test('Lockout remaining is zero when not locked out', () async {
        expect(authService.lockoutRemainingSeconds, 0);
        
        await authService.login('wrong');
        expect(authService.lockoutRemainingSeconds, 0);
      });
    });

    group('PIN Hashing', () {
      test('Same PIN produces same hash', () {
        final hash1 = AuthService.hashPin('1234');
        final hash2 = AuthService.hashPin('1234');
        expect(hash1, hash2);
      });

      test('Different PINs produce different hashes', () {
        final hash1 = AuthService.hashPin('1234');
        final hash2 = AuthService.hashPin('5678');
        expect(hash1, isNot(hash2));
      });

      test('Hash includes sha256 prefix', () {
        final hash = AuthService.hashPin('1234');
        expect(hash, startsWith('sha256='));
      });

      test('Hash is 71 characters (sha256= prefix + 64 hex chars)', () {
        final hash = AuthService.hashPin('1234');
        // "sha256=" (7) + 64 hex characters = 71 total
        expect(hash.length, 71);
      });
    });

    group('State Management', () {
      test('isRegistered is false initially', () async {
        expect(authService.isRegistered, false);
      });

      test('isRegistered is true after registration', () async {
        await authService.registerDoctor('1234');
        expect(authService.isRegistered, true);
      });

      test('isLockedOut is false initially', () async {
        expect(authService.isLockedOut, false);
      });

      test('reset() clears registration and lockout', () async {
        await authService.registerDoctor('1234');
        await authService.login('wrong');
        await authService.login('wrong');
        await authService.login('wrong');
        
        expect(authService.isRegistered, true);
        expect(authService.isLockedOut, true);
        
        await authService.reset();
        expect(authService.isRegistered, false);
        expect(authService.isLockedOut, false);
        expect(authService.failedAttempts, 0);
      });

      test('Initialize checks for expired lockout', () async {
        await authService.registerDoctor('1234');
        
        // Trigger lockout
        await authService.login('wrong');
        await authService.login('wrong');
        await authService.login('wrong');
        expect(authService.isLockedOut, true);
        
        // Create new instance (simulating app restart)
        final authService2 = AuthService(prefs);
        await authService2.initialize();
        
        // Lockout state is preserved (not expired yet)
        expect(authService2.isLockedOut, true);
        
        authService2.dispose();
      });
    });

    group('Integration Scenarios', () {
      test('Complete login flow: register, success, failure, lockout, reset', () async {
        // Register
        final regResult = await authService.registerDoctor('1234');
        expect(regResult, true);
        
        // Successful login
        var loginResult = await authService.login('1234');
        expect(loginResult, 'success');
        expect(authService.failedAttempts, 0);
        
        // Two failed attempts
        loginResult = await authService.login('wrong');
        expect(loginResult, 'invalid_pin');
        loginResult = await authService.login('wrong');
        expect(loginResult, 'invalid_pin');
        expect(authService.failedAttempts, 2);
        expect(authService.isLockedOut, false);
        
        // Third failed attempt triggers lockout
        loginResult = await authService.login('wrong');
        expect(loginResult, 'locked_out');
        expect(authService.isLockedOut, true);
        
        // Correct PIN still fails due to lockout
        loginResult = await authService.login('1234');
        expect(loginResult, 'locked_out');
        
        // Reset
        await authService.reset();
        expect(authService.isRegistered, false);
        expect(authService.isLockedOut, false);
      });

      test('Multiple registration/reset cycles', () async {
        for (int i = 1; i <= 3; i++) {
          final pin = '$i$i$i$i';
          final regResult = await authService.registerDoctor(pin);
          expect(regResult, true);
          
          final loginResult = await authService.login(pin);
          expect(loginResult, 'success');
          
          await authService.reset();
        }
        
        expect(authService.isRegistered, false);
      });
    });
  });
}
