import 'package:flutter/material.dart';
import '../../domain/entities/onboarding_item.dart';
import '../../../../app/theme/app_colors.dart';

class OnboardingContent extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// ICON CONTAINER (always brand orange)
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.primary, // ✅ fixed to brand color
              borderRadius: BorderRadius.circular(26),
            ),
            child: Center(
              child: Icon(item.icon, size: 36, color: Colors.white),
            ),
          ),

          const SizedBox(height: 32),

          /// Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.blackText,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 14),

          /// Description
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.55,
              color: AppColors.blackText.withAlpha(150),
            ),
          ),

          const SizedBox(height: 28),

          /// INFO TILE (flat)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withAlpha(18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Swipe to continue',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackText.withAlpha(170),
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.blackText.withAlpha(120),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
