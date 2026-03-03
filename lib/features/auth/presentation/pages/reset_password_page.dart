import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/utils/snackbar_utils.dart';
import 'package:dinesmart_app/core/widgets/button_widget.dart';
import 'package:dinesmart_app/core/sensors/biometric_service.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/login_page.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/password_reset_viewmodel.dart';
import 'package:dinesmart_app/features/auth/presentation/state/password_reset_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String email;
  final String? token;
  final String? otp;

  const ResetPasswordPage({
    super.key,
    required this.email,
    this.token,
    this.otp,
  });

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isBiometricAvailable = false;
  bool _isAuthenticating = false;
  final _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    await _biometricService.init();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = _biometricService.isBiometricAvailable;
      });
    }
  }

  void _navigateToLogin() {
    AppRoutes.pushAndRemoveUntil(
      context,
      const LoginPage(),
    );
  }

  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();
    print('DEBUG ResetPassword: _handleResetPassword called');
    
    if (_formKey.currentState!.validate()) {
      print('DEBUG ResetPassword: Form validated');
      
      // ✅ Check if biometric is available
      if (_isBiometricAvailable) {
        print('🔐 Biometric available - requesting authentication');
        final isAuthenticated = await _authenticateWithBiometric();
        
        if (!isAuthenticated) {
          print('❌ Biometric authentication failed');
          SnackbarUtils.showError(
            context,
            '${_biometricService.getBiometricTypeString()} authentication failed. Please try again.',
          );
          return;
        }
        print('✅ Biometric authentication successful');
      }
      
      print('DEBUG ResetPassword: Calling resetPassword API with token=${widget.token?.substring(0, 5)}..., otp=${widget.otp}');
      
      // Call the API - the ref.listen() will handle success/error
      await ref
          .read(passwordResetViewModelProvider.notifier)
          .resetPassword(
            email: widget.email,
            newPassword: _newPasswordController.text,
            token: widget.token,
            otp: widget.otp,
          );
      
      print('DEBUG ResetPassword: resetPassword API call completed');
      // Don't check result here - let ref.listen() handle it
    } else {
      print('DEBUG ResetPassword: Form validation failed');
    }
  }

  /// Authenticate using biometric
  Future<bool> _authenticateWithBiometric() async {
    if (_isAuthenticating) return false;
    
    setState(() => _isAuthenticating = true);
    
    try {
      final isAuthenticated = await _biometricService.authenticate(
        reason: 'Verify your ${_biometricService.getBiometricTypeString()} to change password',
      );
      
      return isAuthenticated;
    } finally {
      if (mounted) {
        setState(() => _isAuthenticating = false);
      }
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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

  InputDecoration _fieldDecoration({
    required String hint,
    required Widget suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.blackText.withAlpha(100),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.blackText.withAlpha(40),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.blackText.withAlpha(40),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.withAlpha(170), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.withAlpha(220), width: 1.4),
      ),
      suffixIcon: suffixIcon,
      suffixIconColor: AppColors.blackText.withAlpha(150),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetViewModelProvider);
    final isLoading = state.status == PasswordResetStatus.loading;

    // Listen for password reset completion
    ref.listen(passwordResetViewModelProvider, (previous, next) {
      if (!mounted) return;
      
      print('DEBUG ResetPassword: State changed - status=${next.status}');
      
      if (next.status == PasswordResetStatus.success) {
        print('DEBUG ResetPassword: Success detected, showing snackbar and navigating');
        SnackbarUtils.showSuccess(
          context,
          'Password reset successfully!',
        );
        Future.microtask(() {
          if (mounted) _navigateToLogin();
        });
      } else if (next.status == PasswordResetStatus.error && next.errorMessage != null) {
        print('DEBUG ResetPassword: Error detected: ${next.errorMessage}');
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
                      'Set new password',
                      style: _titleStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your new password below.',
                      style: _subtitleStyle,
                    ),
                    const SizedBox(height: 32),

                    // New Password Field
                    Text(
                      'New Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newPasswordController,
                      enabled: !isLoading,
                      obscureText: _obscureNew,
                      decoration: _fieldDecoration(
                        hint: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscureNew = !_obscureNew,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password Field
                    Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      enabled: !isLoading,
                      obscureText: _obscureConfirm,
                      decoration: _fieldDecoration(
                        hint: '••••••••',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: CustomButton(
                        text: 'Reset Password',
                        onPressed: _handleResetPassword,
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
