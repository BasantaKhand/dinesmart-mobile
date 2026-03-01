import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/utils/snackbar_utils.dart';
import 'package:dinesmart_app/core/widgets/button_widget.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/change_password_page.dart';
import 'package:dinesmart_app/features/auth/presentation/state/auth_state.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authViewModelProvider).user;
    _nameController = TextEditingController(text: user?.ownerName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final notifier = ref.read(authViewModelProvider.notifier);

    await notifier.updateProfile(
      ownerName: _nameController.text,
      phoneNumber: _phoneController.text,
    );

    if (ref.read(authViewModelProvider).errorMessage == null && mounted) {
      SnackbarUtils.showSuccess(context, 'Profile updated successfully');
    } else {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          ref.read(authViewModelProvider).errorMessage!,
        );
      }
    }
  }

  TextStyle get _labelStyle => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.blackText.withAlpha(190),
      );

  InputDecoration _fieldDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: AppColors.primary.withAlpha(180)),
      hintStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.blackText.withAlpha(100),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withAlpha(25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withAlpha(25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withAlpha(15)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: _labelStyle),
      );

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authViewModelProvider).user;
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    final initials = user?.ownerName.isNotEmpty == true
        ? user!.ownerName[0].toUpperCase()
        : (user?.username?.isNotEmpty == true
            ? user!.username![0].toUpperCase()
            : 'U');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withAlpha(20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () => AppRoutes.push(context, const ChangePasswordPage()),
            icon: const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 22),
            tooltip: 'Security Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: (user?.profilePicture != null && user!.profilePicture!.isNotEmpty)
                    ? CachedNetworkImageProvider(user.profilePicture!)
                    : null,
                child: (user?.profilePicture == null || user!.profilePicture!.isEmpty)
                    ? Text(
                        initials,
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.ownerName ?? 'User',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.blackText),
            ),
            Text(
              user?.role?.replaceAll('_', ' ') ?? 'STAFF MEMBER',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.blackText.withAlpha(120),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            _label('Full Name'),
            TextFormField(
              controller: _nameController,
              decoration: _fieldDecoration(hint: 'Enter your name', icon: Icons.person_rounded),
            ),
            const SizedBox(height: 20),
            _label('Email Address'),
            TextFormField(
              controller: _emailController,
              enabled: false,
              decoration: _fieldDecoration(hint: 'Email', icon: Icons.email_rounded),
            ),
            const SizedBox(height: 20),
            _label('Phone Number'),
            TextFormField(
              controller: _phoneController,
              decoration: _fieldDecoration(hint: 'Phone', icon: Icons.phone_rounded),
            ),
            const SizedBox(height: 48),
            CustomButton(
              text: isLoading ? 'Saving...' : 'Update Profile',
              onPressed: isLoading ? null : _saveProfile,
              isLoading: isLoading,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
