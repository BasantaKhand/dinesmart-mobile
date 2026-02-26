import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/change_password_page.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/profile_page.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/login_page.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfileDropDown extends ConsumerWidget {
  const UserProfileDropDown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    final initials = user?.ownerName.isNotEmpty == true 
        ? user!.ownerName[0].toUpperCase() 
        : (user?.username?.isNotEmpty == true ? user!.username![0].toUpperCase() : 'U');

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      onSelected: (value) {
        if (value == 'profile') {
          AppRoutes.push(context, const ProfilePage());
        } else if (value == 'password') {
          AppRoutes.push(context, const ChangePasswordPage());
        } else if (value == 'logout') {
          ref.read(authViewModelProvider.notifier).logout();
          AppRoutes.pushAndRemoveUntil(context, const LoginPage());
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  user?.ownerName ?? user?.username ?? 'User',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  user?.role?.replaceAll('_', ' ') ?? 'STAFF',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: user?.profilePicture != null && user!.profilePicture!.isNotEmpty
                  ? CachedNetworkImageProvider(user.profilePicture!)
                  : null,
              child: (user?.profilePicture == null || user!.profilePicture!.isEmpty)
                  ? Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person_outline_rounded, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 12),
              const Text('Edit Profile'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'password',
          child: Row(
            children: [
              Icon(Icons.lock_outline_rounded, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 12),
              const Text('Change Password'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
              const SizedBox(width: 12),
              const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
        ),
      ],
    );
  }
}
