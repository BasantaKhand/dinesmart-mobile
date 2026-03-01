import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/connectivity_provider.dart';
import '../../app/theme/app_colors.dart';

/// A banner that displays below the AppBar when there's no internet connection
class NoInternetBanner extends ConsumerWidget {
  final VoidCallback? onRetry;
  
  const NoInternetBanner({super.key, this.onRetry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityStreamProvider);
    
    return connectivityAsync.when(
      data: (isConnected) {
        if (isConnected) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.statusError.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: AppColors.statusError.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.wifi_off_rounded,
                color: AppColors.statusError,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No internet connection',
                  style: TextStyle(
                    color: AppColors.statusError,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onRetry != null)
                TextButton.icon(
                  onPressed: () async {
                    // Trigger a connectivity recheck
                    ref.invalidate(connectivityStreamProvider);
                    onRetry?.call();
                  },
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: AppColors.statusError,
                  ),
                  label: Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.statusError,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// A widget that shows a centered illustration when offline and no cached data
class NoInternetPlaceholder extends StatelessWidget {
  final VoidCallback? onRetry;
  final String message;

  const NoInternetPlaceholder({
    super.key,
    this.onRetry,
    this.message = 'No internet connection.\nPlease check your connection and try again.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.statusError.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 60,
                color: AppColors.statusError,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'You\'re Offline',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusError,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
