import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/sensors/accelerometer_service.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/login_page.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:dinesmart_app/features/dashboard/presentation/pages/bill_page.dart';
import 'package:dinesmart_app/features/dashboard/presentation/pages/cart_page.dart';
import 'package:dinesmart_app/features/dashboard/presentation/pages/history_page.dart';
import 'package:dinesmart_app/features/dashboard/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardPage extends ConsumerStatefulWidget{
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int selectedIndex = 0;
  late AccelerometerService _accelerometerService;

  List<Widget> topLevelScreens =[
    HomePage(),
    CartPage(),
    BillPage(),
    HistoryPage()
  ];

  @override
  void initState() {
    super.initState();
    _accelerometerService = AccelerometerService();
    _initializeAccelerometerMonitoring();
  }

  /// Initialize accelerometer for logout detection
  void _initializeAccelerometerMonitoring() {
    _accelerometerService.startMonitoring(
      onShakeDetected: _handleShakeLogout,
      threshold: 15.0, // ✅ Optimized for rotation detection (15-20 typical for device rotation)
    );
    print('🔴 Accelerometer monitoring enabled - rotate or shake device to logout');
  }

  /// Handle logout when shake is detected
  Future<void> _handleShakeLogout() async {
    print('🚨 SHAKE DETECTED - Device motion detected!');
    
    // Show confirmation dialog
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Device Motion Detected', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to logout?\n\n'
          'Your device movement was detected. This may indicate an unauthorized access attempt.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print('✅ User cancelled logout - resumed session');
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.blue, fontSize: 16)),
          ),
          // Logout button
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// Perform logout
  void _performLogout() {
    _accelerometerService.stopMonitoring();
    ref.read(authViewModelProvider.notifier).logout();
    AppRoutes.pushAndRemoveUntil(context, const LoginPage());
  }

  @override
  void dispose() {
    _accelerometerService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
          title: const Text('Dashboard'),
          leading: PopupMenuButton<String>(
            icon: const Icon(
              Icons.menu, // ☰ three horizontal lines
              color: Colors.black,
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _performLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'logout',
                child: Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

      body: topLevelScreens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(  
        type: BottomNavigationBarType.fixed,
        items: const [  
          BottomNavigationBarItem(  
            icon: Icon(Icons.home),
            label: 'Home'
          ),
          BottomNavigationBarItem(  
            icon: Icon(Icons.shopping_bag),
            label: 'Cart'
          ),
          BottomNavigationBarItem(  
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Bill'
          ),
          BottomNavigationBarItem(  
            icon: Icon(Icons.history),
            label: 'History'
          )
        ],
        currentIndex: selectedIndex,
        onTap: (index) {
          setState((){
            selectedIndex = index;
          });
        }

      ),
      

      
      
    );
  }
}