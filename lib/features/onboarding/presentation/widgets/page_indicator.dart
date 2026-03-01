import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class PageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentPage;

  const PageIndicator({
    super.key,
    required this.itemCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final bool isActive = index == currentPage;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.border,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
