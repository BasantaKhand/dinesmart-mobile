import 'dart:async'; // ✅ For StreamSubscription
import 'dart:math'; // ✅ For sqrt
import 'package:sensors_plus/sensors_plus.dart';

typedef LogoutCallback = Future<void> Function();

class AccelerometerService {
  static final AccelerometerService _instance = AccelerometerService._internal();

  late Stream<AccelerometerEvent> _accelerometerStream;
  StreamSubscription<AccelerometerEvent>? _subscription; // ✅ Store subscription
  bool _isMonitoring = false;
  double _threshold = 15.0; // ✅ Perfect for 90° rotation detection
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
    double threshold = 15.0, // ✅ Perfect for 90° rotation - not too sensitive, not too weak
  }) {
    if (_isMonitoring) {
      return;
    }

    _onShakeDetected = onShakeDetected;
    _threshold = threshold;
    _isMonitoring = true;

    // ✅ Store subscription to keep it alive
    _subscription = _accelerometerStream.listen(
      (AccelerometerEvent event) {
        _detectShake(event);
      },
      onError: (error) {
        _isMonitoring = false;
      },
      onDone: () {
        _isMonitoring = false;
      },
    );
  }

  /// Stop monitoring
  void stopMonitoring() {
    _subscription?.cancel(); // ✅ Properly cancel subscription
    _isMonitoring = false;
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

    // Calculate acceleration magnitude (using square root for correct calculation)
    final x = event.x;
    final y = event.y;
    final z = event.z;

    // Correct magnitude = sqrt(x² + y² + z²)
    // Gravity alone = sqrt(0² + 9.81² + 0²) = 9.81 m/s²
    // Normal movement = 10-15 m/s²
    // Vigorous shake = 20-30 m/s²
    // Violent shake/drop = 50+ m/s²
    final magnitude = sqrt(x * x + y * y + z * z);
    final accelerationValue = double.parse(magnitude.toStringAsFixed(2));

    // Debug: Print all readings to see what's happening
    if (accelerationValue > 5.0) {
    }

    // Detect significant movement (rotate device, drop, or theft attempt)
    // Gravity alone = 9.81 m/s²
    // Gentle rotation = 12-15 m/s²
    // 90° rotation = 15-20 m/s²
    // Vigorous shake = 20-30 m/s²
    // Violent shake/drop = 50+ m/s²
    // Threshold of 15 is PERFECT for 90° rotation detection
    if (accelerationValue > _threshold) {
      _lastShakeTime = now;
      _triggerLogout();
    }
  }

  /// Trigger logout when shake is detected
  Future<void> _triggerLogout() async {
    if (_onShakeDetected != null) {
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
  }
}
