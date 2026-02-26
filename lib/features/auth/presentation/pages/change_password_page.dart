import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/utils/snackbar_utils.dart';
import 'package:dinesmart_app/features/auth/presentation/state/auth_state.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:dinesmart_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/pages/waiter_dashboard_page.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/pages/cashier_dashboard_page.dart';
import 'package:dinesmart_app/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authViewModelProvider.notifier).changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(context, 'Password changed successfully!');
        if (next.user?.role == 'WAITER') {
          AppRoutes.pushAndRemoveUntil(context, const WaiterDashboardPage());
        } else if (next.user?.role == 'CASHIER') {
          AppRoutes.pushAndRemoveUntil(context, const CashierDashboardPage());
        } else if (next.user?.role == 'RESTAURANT_ADMIN') {
          AppRoutes.pushAndRemoveUntil(context, const AdminDashboardPage());
        } else {
          AppRoutes.pushAndRemoveUntil(context, const DashboardPage());
        }
      } else if (next.status == AuthStatus.passwordChangeRequired &&
          next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () => AppRoutes.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Change\nPassword',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You must update your temporary password to secure your account.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: 'Current Password',
                      obscure: _obscureCurrent,
                      onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                    const SizedBox(height: 24),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      obscure: _obscureNew,
                      onToggle: () => setState(() => _obscureNew = !_obscureNew),
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      obscure: _obscureConfirm,
                      onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (value) {
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleChangePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Update Password',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'This field is required';
                }
                return null;
              },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '••••••••',
            hintStyle: TextStyle(color: Colors.grey[300]),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey[400],
                size: 20,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
