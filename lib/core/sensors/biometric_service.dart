import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;
  bool _isInitialized = false;
  List<BiometricType> _availableBiometrics = [];

  BiometricService._internal();

  factory BiometricService() => _instance;

  /// Must be awaited before checking [isBiometricAvailable].
  /// Safe to call multiple times — only runs once.
  Future<void> init() async {
    if (_isInitialized) return;
    try {
      _isBiometricAvailable = await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
      if (_isBiometricAvailable) {
        _availableBiometrics = await _localAuth.getAvailableBiometrics();
        print('✅ Biometrics available: $_availableBiometrics');
      } else {
        print('❌ Biometrics not available on this device');
      }
    } catch (e) {
      print('❌ Error checking biometrics: $e');
      _isBiometricAvailable = false;
    } finally {
      _isInitialized = true;
    }
  }

  /// Whether biometrics are available. Call [init] first.
  bool get isBiometricAvailable => _isBiometricAvailable;

  /// List of available biometric types.
  List<BiometricType> get availableBiometrics => _availableBiometrics;

  /// Authenticate using biometric (fingerprint / face).
  Future<bool> authenticate({required String reason}) async {
    if (!_isBiometricAvailable) {
      print('❌ Biometric not available');
      return false;
    }
    try {
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      print(result ? '✅ Biometric auth succeeded' : '❌ Biometric auth failed/cancelled');
      return result;
    } catch (e) {
      print('❌ Biometric error: $e');
      return false;
    }
  }

  /// Human-readable name of the primary biometric type.
  String getBiometricTypeString() {
    if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (_availableBiometrics.contains(BiometricType.face)) {
      return 'Face Recognition';
    } else if (_availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris Scan';
    }
    return 'Biometric';
  }

  /// Icon to use in UI for the available biometric type.
  String getBiometricIconAsset() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return 'assets/icons/face_id.png';
    }
    return 'assets/icons/fingerprint.png';
  }
}
