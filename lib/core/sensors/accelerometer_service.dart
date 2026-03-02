import 'dart:async'; // ✅ For StreamSubscription
import 'package:sensors_plus/sensors_plus.dart';

typedef LogoutCallback = Future<void> Function();

class AccelerometerService {
  static final AccelerometerService _instance = AccelerometerService._internal();

  late Stream<AccelerometerEvent> _accelerometerStream;
  StreamSubscription<AccelerometerEvent>? _subscription; // ✅ Store subscription
  bool _isMonitoring = false;
  double _threshold = 15.0; // ✅ Lower default threshold for rotation detection
  DateTime? _lastShakeTime;
  LogoutCallback? _onShakeDetected;

  AccelerometerService._internal() {
    _accelerometerStream = accelerometerEvents;
  }

  factory AccelerometerService() {
    return _instance;
  }

  /// Start monitoring device shake/acceleration
  void startMonitoring({
    required LogoutCallback onShakeDetected,
    double threshold = 15.0, // ✅ Lower default for rotation detection
  }) {
    if (_isMonitoring) {
      print('⚠️ Accelerometer already monitoring');
      return;
    }

    _onShakeDetected = onShakeDetected;
    _threshold = threshold;
    _isMonitoring = true;

    print('✅ Accelerometer monitoring started (threshold: $_threshold)');
    print('📱 Rotating device should trigger logout alert...');

    // ✅ Store subscription to keep it alive
    _subscription = _accelerometerStream.listen(
      (AccelerometerEvent event) {
        _detectShake(event);
      },
      onError: (error) {
        print('❌ Accelerometer error: $error');
        _isMonitoring = false;
      },
      onDone: () {
        print('⛔ Accelerometer stream closed');
        _isMonitoring = false;
      },
    );
  }

  /// Stop monitoring
  void stopMonitoring() {
    _subscription?.cancel(); // ✅ Properly cancel subscription
    _isMonitoring = false;
    print('⛔ Accelerometer monitoring stopped');
  }

  /// Detect shake/unusual movement
  void _detectShake(AccelerometerEvent event) {
    if (!_isMonitoring) return;

    final now = DateTime.now();

    // Ignore rapid successive shakes (debounce - 500ms to avoid spam)
    if (_lastShakeTime != null &&
        now.difference(_lastShakeTime!).inMilliseconds < 500) {
      return;
    }

    // Calculate acceleration magnitude
    final x = event.x;
    final y = event.y;
    final z = event.z;

    // More realistic acceleration calculation
    final acceleration = (x * x + y * y + z * z).toStringAsFixed(2);
    final accelerationValue = double.parse(acceleration);

    // Debug: Print all readings to see what's happening
    if (accelerationValue > 5.0) {
      print('📊 Device motion detected: X=$x, Y=$y, Z=$z, Magnitude=$accelerationValue (threshold: $_threshold)');
    }

    // Detect significant movement (rotate device, drop, or theft attempt)
    // Rotation typically produces 10-20 m/s² acceleration
    // Threshold of 15 catches rotation, 25+ catches violent shakes
    if (accelerationValue > _threshold) {
      _lastShakeTime = now;
      print('🚨 SUSPICIOUS MOTION DETECTED! Acceleration: $accelerationValue (threshold: $_threshold)');
      _triggerLogout();
    }
  }

  /// Trigger logout when shake is detected
  Future<void> _triggerLogout() async {
    if (_onShakeDetected != null) {
      print('🔐 Executing logout due to suspicious shake detected');
      await _onShakeDetected!();
    }
  }

  /// Check if monitoring is active
  bool get isMonitoring => _isMonitoring;

  /// Get current threshold
  double get threshold => _threshold;

  /// Set custom threshold
  void setThreshold(double newThreshold) {
    _threshold = newThreshold;
    print('🔧 Accelerometer threshold updated to: $_threshold');
  }
}
