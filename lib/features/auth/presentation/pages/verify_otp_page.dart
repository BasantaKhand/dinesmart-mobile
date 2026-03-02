import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/utils/snackbar_utils.dart';
import 'package:dinesmart_app/core/widgets/button_widget.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/reset_password_page.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/password_reset_viewmodel.dart';
import 'package:dinesmart_app/features/auth/presentation/state/password_reset_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyOtpPage extends ConsumerStatefulWidget {
  final String email;

  const VerifyOtpPage({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends ConsumerState<VerifyOtpPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Rebuild when OTP value changes to update button state
    _otpController.addListener(() {
      setState(() {});
    });
  }

  void _navigateToResetPassword(String otp) {
    AppRoutes.push(
      context,
      ResetPasswordPage(email: widget.email, otp: otp),
    );
  }

  Future<void> _handleVerifyOtp() async {
    FocusScope.of(context).unfocus();
    print('DEBUG VerifyOTP: _handleVerifyOtp called');
    
    if (_formKey.currentState!.validate()) {
      print('DEBUG VerifyOTP: Form validated, OTP=${_otpController.text}');
      
      // Call the API - the ref.listen() will handle navigation
      await ref
          .read(passwordResetViewModelProvider.notifier)
          .verifyPasswordResetOtp(
            email: widget.email,
            otp: _otpController.text.trim(),
          );
      
      print('DEBUG VerifyOTP: verifyPasswordResetOtp completed');
      // Don't check result here - let ref.listen() handle it
    } else {
      print('DEBUG VerifyOTP: Form validation failed');
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
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
      
      print('DEBUG VerifyOTP: State changed - status=${next.status}');
      
      if (next.status == PasswordResetStatus.success) {
        print('DEBUG VerifyOTP: Success status detected, navigating to reset password');
        Future.microtask(() {
          if (mounted) _navigateToResetPassword(_otpController.text.trim());
        });
      } else if (next.status == PasswordResetStatus.error && next.errorMessage != null) {
        print('DEBUG VerifyOTP: Error status detected: ${next.errorMessage}');
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
                      'Verify your code',
                      style: _titleStyle,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter the 6-digit code we sent to',
                          style: _subtitleStyle,
                        ),
                        Text(
                          widget.email,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // OTP Input
                    Text(
                      '6-digit code',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _otpController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                        color: AppColors.blackText,
                      ),
                      decoration: InputDecoration(
                        hintText: '000000',
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 8,
                          color: AppColors.blackText.withAlpha(100),
                        ),
                        counter: SizedBox.shrink(),
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
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (value) {
                        // Only allow digits
                        _otpController.text = value.replaceAll(RegExp(r'[^0-9]'), '');
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'OTP is required';
                        }
                        if (value.length != 6) {
                          return 'Please enter a valid 6-digit code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'The code will expire in 10 minutes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackText.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: CustomButton(
                        text: 'Verify Code',
                        onPressed: _otpController.text.length == 6 && !isLoading
                            ? _handleVerifyOtp
                            : null,
                        isLoading: isLoading,
                        height: 56,
                      ),
                    ),

                    // Help Section
                    const SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundPrimary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.blackText.withAlpha(40)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Tip',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check your email (including spam folder) for the 6-digit verification code. ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.blackText.withAlpha(150),
                              height: 1.5,
                            ),
                          ),
                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () => Navigator.pop(context),
                            child: Text(
                              'Request a new code',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Back to Login
                    const SizedBox(height: 24),
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
