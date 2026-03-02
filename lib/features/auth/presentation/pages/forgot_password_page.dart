import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/utils/snackbar_utils.dart';
import 'package:dinesmart_app/core/widgets/button_widget.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/password_reset_viewmodel.dart';
import 'package:dinesmart_app/features/auth/presentation/state/password_reset_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String _selectedMethod = 'otp'; // 'otp' or 'link'

  void _navigateToVerifyOtp() {
    AppRoutes.push(
      context,
      VerifyOtpPage(email: _emailController.text.trim()),
    );
  }

  Future<void> _handleForgotPassword() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      try {
        final result = await ref
            .read(passwordResetViewModelProvider.notifier)
            .forgotPassword(
              email: _emailController.text.trim(),
              method: _selectedMethod,
            );

        if (mounted) {
          print('DEBUG: ForgotPassword result=$result, method=$_selectedMethod');
          if (result) {
            if (_selectedMethod == 'otp') {
              print('DEBUG: Navigating to verify OTP page');
              _navigateToVerifyOtp();
            } else {
              print('DEBUG: Showing success snackbar for link method');
              SnackbarUtils.showSuccess(
                context,
                'Reset link sent! Check your email.',
              );
            }
          } else {
            final error = ref.read(passwordResetViewModelProvider).errorMessage;
            print('DEBUG: Error occurred: $error');
            SnackbarUtils.showError(context, error ?? 'Failed to send reset request');
          }
        }
      } catch (e) {
        print('DEBUG: Exception in _handleForgotPassword: $e');
        if (mounted) {
          SnackbarUtils.showError(context, 'Unexpected error: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  TextStyle get _titleStyle => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: AppColors.blackText,
    letterSpacing: -0.2,
  );

  TextStyle get _subtitleStyle => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.blackText.withAlpha(150),
    height: 1.5,
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetViewModelProvider);
    final isLoading = state.status == PasswordResetStatus.loading;

    // Listen for state changes
    ref.listen(passwordResetViewModelProvider, (previous, next) {
      if (!mounted) return;
      
      print('DEBUG: State changed - status=${next.status}');
      
      if (next.status == PasswordResetStatus.success) {
        print('DEBUG: Success status detected');
        if (_selectedMethod == 'otp') {
          print('DEBUG: Navigating to OTP page');
          Future.microtask(() {
            if (mounted) _navigateToVerifyOtp();
          });
        } else {
          print('DEBUG: Showing success message for link method');
          SnackbarUtils.showSuccess(
            context,
            'Reset link sent! Check your email.',
          );
        }
      } else if (next.status == PasswordResetStatus.error && next.errorMessage != null) {
        print('DEBUG: Error status detected: ${next.errorMessage}');
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return WillPopScope(
      onWillPop: () async {
        if (isLoading) return false;
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: isLoading
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      'Reset your password',
                      style: _titleStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose how you\'d like to reset your password',
                      style: _subtitleStyle,
                    ),
                    const SizedBox(height: 24),

                    // Email Input
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'you@restaurant.com',
                        hintStyle: TextStyle(
                          color: AppColors.blackText.withAlpha(100),
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.blackText.withAlpha(150),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.blackText.withAlpha(40)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.blackText.withAlpha(40)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                            .hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Method Selection
                    Text(
                      'Reset method',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // OTP Option
                    GestureDetector(
                      onTap: isLoading ? null : () => setState(() => _selectedMethod = 'otp'),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedMethod == 'otp'
                                ? AppColors.primary
                                : AppColors.blackText.withAlpha(40),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: _selectedMethod == 'otp'
                              ? AppColors.primary.withOpacity(0.05)
                              : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'otp',
                              groupValue: _selectedMethod,
                              onChanged: isLoading ? null : (value) => setState(() => _selectedMethod = value!),
                              activeColor: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '6-digit code (Recommended)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.blackText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Get a 6-digit code via email. Enter it in the app to reset your password.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.blackText.withAlpha(150),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Link Option
                    GestureDetector(
                      onTap: isLoading ? null : () => setState(() => _selectedMethod = 'link'),
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedMethod == 'link'
                                ? AppColors.primary
                                : AppColors.blackText.withAlpha(40),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: _selectedMethod == 'link'
                              ? AppColors.primary.withOpacity(0.05)
                              : Colors.white,
                        ),
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'link',
                              groupValue: _selectedMethod,
                              onChanged: isLoading ? null : (value) => setState(() => _selectedMethod = value!),
                              activeColor: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reset link',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.blackText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Get a password reset link via email. Click the link to reset your password.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.blackText.withAlpha(150),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: CustomButton(
                        text: _selectedMethod == 'otp' ? 'Send Code' : 'Send Link',
                        onPressed: _handleForgotPassword,
                        isLoading: isLoading,
                        height: 56,
                      ),
                    ),

                    // Back to Login
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: isLoading ? null : () => Navigator.pop(context),
                        child: Text(
                          'Back to login',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
