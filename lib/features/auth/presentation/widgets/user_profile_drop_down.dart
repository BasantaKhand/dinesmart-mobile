import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/change_password_page.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/profile_page.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/login_page.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:dinesmart_app/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfileDropDown extends ConsumerWidget {
  const UserProfileDropDown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.user;
    final session = ref.read(userSessionServiceProvider);

    final displayName = user?.ownerName.isNotEmpty == true
      ? user!.ownerName
      : (session.getCurrentUserFullName()?.isNotEmpty == true
        ? session.getCurrentUserFullName()!
        : 'User');

    final roleText = user?.role?.isNotEmpty == true
      ? user!.role!
      : (session.getCurrentUserRole()?.isNotEmpty == true
        ? session.getCurrentUserRole()!
        : 'STAFF');

    final avatarUrl = user?.profilePicture?.isNotEmpty == true
      ? user!.profilePicture
      : session.getCurrentUserProfilePicture();

    final initials = displayName.isNotEmpty
      ? displayName[0].toUpperCase()
      : (user?.username?.isNotEmpty == true
          ? user!.username![0].toUpperCase()
              : 'U');

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade200, // ✅ subtle light grey divider
          thickness: 1,
          space: 1,
        ),
      ),
      child: PopupMenuButton<String>(
        offset: const Offset(0, 50),
        color: Colors.white, // ✅ popup menu background white
        surfaceTintColor: Colors.white, // ✅ remove material 3 tint
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    roleText.replaceAll('_', ' '),
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
                backgroundColor: AppColors.primary,
                backgroundImage:
                  avatarUrl != null && avatarUrl.isNotEmpty
                  ? CachedNetworkImageProvider(avatarUrl)
                    : null,
                child:
                  (avatarUrl == null || avatarUrl.isEmpty)
                    ? Text(
                        initials,
                        style: const TextStyle(
                          color: AppColors.whiteText,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
                Icon(
                  Icons.person_outline_rounded,
                  size: 20,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 12),
                const Text('Edit Profile'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'password',
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 20,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 12),
                const Text('Change Password'),
              ],
            ),
          ),
          const PopupMenuDivider(height: 1),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: Colors.redAccent,
                ),
                const SizedBox(width: 12),
                const Text('Logout', style: TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
