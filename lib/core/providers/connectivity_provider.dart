import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity/network_info.dart';

/// Stream provider that emits connectivity status changes
final connectivityStreamProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.read(networkInfoProvider);
  final connectivity = Connectivity();
  
  // Controller to emit connectivity changes
  final controller = StreamController<bool>();
  
  // Check initial connectivity
  networkInfo.isConnected.then((isConnected) {
    controller.add(isConnected);
  });
  
  // Listen for connectivity changes
  final subscription = connectivity.onConnectivityChanged.listen((results) async {
    if (results.contains(ConnectivityResult.none)) {
      controller.add(false);
    } else {
      // Verify actual internet connectivity
      final hasInternet = await networkInfo.isConnected;
      controller.add(hasInternet);
    }
  });
  
  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });
  
  return controller.stream;
});

/// Simple state provider to track connectivity (useful for imperative checks)
final isConnectedProvider = StateProvider<bool>((ref) => true);
