import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerformAppAuthentication {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Authenticate to access the app',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      return false;
    }
  }
}

class AuthService {
  Future<bool> isFingerprintEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('fingerprintEnabled') ?? false;
  }

  Future<bool> authenticate() async {
    return await PerformAppAuthentication.authenticate();
  }

  Future<void> setFingerprintEnabled(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fingerprintEnabled', value);
  }
}