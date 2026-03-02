import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();

  late LocalAuthentication _localAuth;
  bool _isBiometricAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  BiometricService._internal() {
    _localAuth = LocalAuthentication();
    _initBiometric();
  }

  factory BiometricService() {
    return _instance;
  }

  Future<void> _initBiometric() async {
    try {
      _isBiometricAvailable = await _localAuth.canCheckBiometrics;
      if (_isBiometricAvailable) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
        print('✅ Biometrics available: $_availableBiometrics');
      } else {
        print('❌ Biometrics not available on this device');
      }
    } catch (e) {
      print('❌ Error checking biometrics: $e');
    }
  }

  /// Check if biometric is available
  bool get isBiometricAvailable => _isBiometricAvailable;

  /// Get list of available biometric types
  List<BiometricType> get availableBiometrics => _availableBiometrics;

  /// Authenticate using biometric (fingerprint/face)
  Future<bool> authenticate({
    required String reason,
  }) async {
    try {
      if (!_isBiometricAvailable) {
        print('❌ Biometric not available');
        return false;
      }

      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
        ),
      );

      if (isAuthenticated) {
        print('✅ Biometric authentication successful');
        return true;
      } else {
        print('❌ Biometric authentication failed or cancelled');
        return false;
      }
    } catch (e) {
      print('❌ Biometric error: $e');
      return false;
    }
  }

  /// Get biometric type string for display
  String getBiometricTypeString() {
    if (_availableBiometrics.isEmpty) return 'Biometric';
    
    if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face Recognition';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris Scan';
    }
    return 'Biometric';
  }
}
