import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';


class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();


  Future<bool> canCheckBiometrics() async {
    if (kIsWeb) return false;
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }


  Future<bool> authenticate() async {
    if (kIsWeb) return false;
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Unlock your notes',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      return false;
    }
  }


  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return [];
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
}
