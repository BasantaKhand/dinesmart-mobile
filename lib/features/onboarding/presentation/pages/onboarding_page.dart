import 'package:dinesmart_app/core/widgets/button_widget.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/login_page.dart';
import 'package:dinesmart_app/features/onboarding/presentation/widgets/onboarding_content.dart';
import 'package:dinesmart_app/features/onboarding/presentation/widgets/page_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/onboarding_item.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/routes/app_routes.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;

  final List<OnboardingItem> _onboardingItems = const [
    OnboardingItem(
      title: 'Manage Tables Smartly',
      description:
          'View table availability in real time and assign seats instantly to keep your restaurant running smoothly.',
      icon: Icons.table_restaurant_rounded,
      color: AppColors.onboarding1Primary,
      gradientColors: [
        AppColors.onboarding1Primary,
        AppColors.onboarding1Secondary,
      ],
    ),
    OnboardingItem(
      title: 'Take Orders Faster',
      description:
          'Place and manage customer orders quickly with an intuitive flow from table to kitchen ensuring efficiency.',
      icon: Icons.shopping_cart_checkout_rounded,
      color: AppColors.onboarding2Primary,
      gradientColors: [
        AppColors.onboarding2Primary,
        AppColors.onboarding2Secondary,
      ],
    ),
    OnboardingItem(
      title: 'Easy Billing & History',
      description:
          'Generate bills in seconds and track daily sales and order history with complete accuracy and reliability.',
      icon: Icons.receipt_long_rounded,
      color: AppColors.onboarding3Primary,
      gradientColors: [
        AppColors.onboarding3Primary,
        AppColors.onboarding3Secondary,
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _animationController.forward();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _animationController
      ..reset()
      ..forward();
  }

  void _nextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 420), // ✅ smoother
        curve: Curves.easeInOut, // ✅ smooth swipe feel
      );
    } else {
      _navigateToLogin();
    }
  }

  void _skipOnboarding() => _navigateToLogin();

  void _navigateToLogin() {
    AppRoutes.pushReplacement(context, const LoginPage());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ flat background
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar (Skip - no border, no stroke)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      backgroundColor: Colors.transparent, // ✅ flat
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      overlayColor: Colors.black.withAlpha(10),
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.blackText.withAlpha(170),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(), // ✅ smoother feel
                onPageChanged: _onPageChanged,
                itemCount: _onboardingItems.length,
                itemBuilder: (context, index) {
                  return FadeTransition(
                    opacity: _animationController,
                    child: OnboardingContent(item: _onboardingItems[index]),
                  );
                },
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  PageIndicator(
                    itemCount: _onboardingItems.length,
                    currentPage: _currentPage,
                  ),
                  const SizedBox(height: 24),

                  // Flat solid button (brand orange)
                  CustomButton(
                    text: _currentPage == _onboardingItems.length - 1
                        ? 'Get Started'
                        : 'Next',
                    onPressed: _nextPage,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
