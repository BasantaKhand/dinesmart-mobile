import 'dart:async';
import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/services/storage/user_session_service.dart';
import 'package:dinesmart_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/pages/waiter_dashboard_page.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/pages/cashier_dashboard_page.dart';
import 'package:dinesmart_app/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:dinesmart_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  double progressValue = 0.0;

  @override
  void initState() {
    super.initState();

    // Controls circular rotating loader
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Fake loading progress (2 seconds)
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        progressValue += 0.05;
      });

      if (progressValue >= 2) {
        timer.cancel();

        _navigateToNext();
      }
    });
  }
  
  Future<void> _navigateToNext() async {
    // Check if user is already logged in
    final userSessionService = ref.read(userSessionServiceProvider);
    final isLoggedIn = userSessionService.isLoggedIn();

    if (isLoggedIn) {
      // Navigate based on role if user is logged in
      final role = userSessionService.getCurrentUserRole();
      if (role == 'WAITER') {
        AppRoutes.pushReplacement(context, const WaiterDashboardPage());
      } else if (role == 'CASHIER') {
        AppRoutes.pushReplacement(context, const CashierDashboardPage());
      } else if (role == 'RESTAURANT_ADMIN') {
        AppRoutes.pushReplacement(context, const AdminDashboardPage());
      } else {
        AppRoutes.pushReplacement(context, const DashboardPage());
      }
    } else {
      // Navigate to Onboarding if user is not logged in
      AppRoutes.pushReplacement(context, const OnboardingPage());
    }
  }

  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// LOGO
          ClipOval(
            child: Image.asset(
              'assets/logos/dinesmart_logo.png',
              width: 250,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 40),

          /// ROTATING CIRCLE LOADER
          RotationTransition(
            turns: _controller,
            child: const Icon(
              Icons.autorenew_outlined,
              size: 30,
              color: AppColors.opacityTextTwo , // green
            ),
          ),

          const SizedBox(height: 16),

          /// PROGRESS BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:170),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 6,

              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation(
                Color(0xFF2ECC71), // green fill
              ),
            ),
          ),
        ],
      ),
    );
  }
}
