import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/utils/snackbar_utils.dart';
import 'package:dinesmart_app/core/widgets/button_widget.dart';
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
      await ref
          .read(authViewModelProvider.notifier)
          .changePassword(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );
    }
  }

  TextStyle get _titleStyle => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.blackText,
    letterSpacing: -0.5,
  );

  TextStyle get _subtitleStyle => TextStyle(
    fontSize: 14,
    height: 1.4,
    fontWeight: FontWeight.w500,
    color: AppColors.blackText.withAlpha(150),
  );

  TextStyle get _labelStyle => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.blackText.withAlpha(190),
  );

  InputDecoration _fieldDecoration({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.blackText.withAlpha(120),
      ),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black.withAlpha(25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primary.withAlpha(140),
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.withAlpha(170), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.withAlpha(220), width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: _labelStyle),
  );

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(context, 'Password updated successfully!');
        if (next.user?.role == 'WAITER') {
          AppRoutes.pushAndRemoveUntil(context, const WaiterDashboardPage());
        } else if (next.user?.role == 'CASHIER') {
          AppRoutes.pushAndRemoveUntil(context, const CashierDashboardPage());
        } else if (next.user?.role == 'RESTAURANT_ADMIN') {
          AppRoutes.pushAndRemoveUntil(context, const AdminDashboardPage());
        } else {
          AppRoutes.pushAndRemoveUntil(context, const DashboardPage());
        }
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withAlpha(20),
        leading: IconButton(
          onPressed: () => AppRoutes.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Change Password', style: _titleStyle),
              const SizedBox(height: 8),
              Text(
                'Update your password to keep your account secure.',
                style: _subtitleStyle,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _label('Current Password'),
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: _obscureCurrent,
                      decoration: _fieldDecoration(
                        hint: 'Enter current password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrent
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppColors.blackText.withAlpha(120),
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscureCurrent = !_obscureCurrent,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter current password';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _label('New Password'),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      decoration: _fieldDecoration(
                        hint: 'Enter new password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppColors.blackText.withAlpha(120),
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6)
                          return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _label('Confirm New Password'),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      decoration: _fieldDecoration(
                        hint: 'Confirm new password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppColors.blackText.withAlpha(120),
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      text: isLoading ? 'Updating...' : 'Update Password',
                      onPressed: isLoading ? null : _handleChangePassword,
                      isLoading: isLoading,
                      backgroundColor: AppColors.primary,
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
}
