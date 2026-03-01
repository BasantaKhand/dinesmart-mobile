import 'dart:async';
import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/services/storage/user_session_service.dart';
import 'package:dinesmart_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/pages/waiter_dashboard_page.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/pages/cashier_dashboard_page.dart';
import 'package:dinesmart_app/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/auth_viewmodel.dart';
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

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // Fake loading progress (1.5 seconds total)
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        progressValue += 0.04; // Increments to 1.0 in ~1.25 seconds
        if (progressValue > 1.0) progressValue = 1.0;
      });

      if (progressValue >= 1.0) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) _navigateToNext();
        });
      }
    });
  }

  Future<void> _navigateToNext() async {
    final userSessionService = ref.read(userSessionServiceProvider);
    final hasValidSession = await userSessionService.hasValidSession();

    if (hasValidSession) {
      await ref.read(authViewModelProvider.notifier).hydrateFromSession();

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
      await userSessionService.clearSession();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// LOGO
            ClipOval(
              child: Image.asset(
                'assets/logos/logo.png',
                width: 220,
                height: 220,
                scale: 1,
                fit: BoxFit.contain,
              ),
            ),

            const SizedBox(height: 50),

            /// ROTATING LOADER
            RotationTransition(
              turns: _controller,
              child: const Icon(
                Icons.autorenew_outlined,
                size: 32,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: 24),

            /// PROGRESS BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 4,
                  backgroundColor: Colors.grey.withAlpha(30),
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
