import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/sensors/biometric_service.dart';
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

  // ── Biometrics ──────────────────────────────────────────────────────────────
  final _biometricService = BiometricService();
  bool _isBiometricAvailable = false;
  bool _biometricVerified = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _initBiometrics();
  }

  Future<void> _initBiometrics() async {
    await _biometricService.init();
    if (mounted) {
      setState(() {
        _isBiometricAvailable = _biometricService.isBiometricAvailable;
      });
      // Auto-prompt fingerprint when the page opens if available
      if (_isBiometricAvailable) {
        await _authenticateWithBiometric();
      }
    }
  }

  Future<void> _authenticateWithBiometric() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    try {
      final success = await _biometricService.authenticate(
        reason: 'Verify your ${_biometricService.getBiometricTypeString()} to change your password',
      );
      if (mounted) {
        setState(() => _biometricVerified = success);
        if (!success) {
          SnackbarUtils.showError(
            context,
            '${_biometricService.getBiometricTypeString()} not recognised. Tap the box to try again.',
          );
        }
      }
    } catch (e) {
      // Handle specific biometric errors
      String message = 'Biometric error. Tap to try again.';
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('notenrolled') || errStr.contains('not_enrolled')) {
        message = 'No fingerprint enrolled on this device. Go to device Settings → Security → Fingerprint.';
      } else if (errStr.contains('locked') || errStr.contains('lockout')) {
        message = 'Too many attempts. Fingerprint temporarily locked. Try again in 30 seconds.';
      } else if (errStr.contains('passcode') || errStr.contains('no_device_credential')) {
        message = 'No screen lock set up. Enable fingerprint in device Settings.';
      }
      if (mounted) {
        setState(() => _biometricVerified = false);
        SnackbarUtils.showError(context, message);
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    // If fingerprint is available but not yet verified, prompt first
    if (_isBiometricAvailable && !_biometricVerified) {
      await _authenticateWithBiometric();
      if (!_biometricVerified) return; // still not verified — stop
    }

    await ref
        .read(authViewModelProvider.notifier)
        .changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
  }

  // ── Styles ───────────────────────────────────────────────────────────────────

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

  // ── Biometric Badge ──────────────────────────────────────────────────────────

  Widget _buildBiometricBadge() {
    if (!_isBiometricAvailable) return const SizedBox.shrink();

    final verified = _biometricVerified;
    final label = _biometricService.getBiometricTypeString();

    return GestureDetector(
      onTap: verified ? null : _authenticateWithBiometric,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 28),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: verified
              ? Colors.green.withAlpha(20)
              : AppColors.primary.withAlpha(12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: verified
                ? Colors.green.withAlpha(80)
                : AppColors.primary.withAlpha(60),
            width: 1.4,
          ),
        ),
        child: Row(
          children: [
            // Icon circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: verified
                    ? Colors.green.withAlpha(30)
                    : AppColors.primary.withAlpha(20),
              ),
              child: _isAuthenticating
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    )
                  : Icon(
                      verified
                          ? Icons.check_circle_rounded
                          : Icons.fingerprint_rounded,
                      color: verified ? Colors.green : AppColors.primary,
                      size: 24,
                    ),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    verified
                        ? '$label Verified'
                        : 'Verify with $label',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: verified ? Colors.green.shade700 : AppColors.blackText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    verified
                        ? 'Identity confirmed. You can now update your password.'
                        : 'Tap to authenticate before changing password.',
                    style: TextStyle(
                      fontSize: 12,
                      color: verified
                          ? Colors.green.shade600
                          : AppColors.blackText.withAlpha(130),
                    ),
                  ),
                ],
              ),
            ),
            if (!verified && !_isAuthenticating)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary.withAlpha(180),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

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

    // Determine if submit should be enabled
    final canSubmit = !isLoading &&
        (!_isBiometricAvailable || _biometricVerified);

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
              const SizedBox(height: 28),

              // ── Fingerprint badge ──
              _buildBiometricBadge(),

              // ── Form ──
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
                      text: isLoading
                          ? 'Updating...'
                          : (_isBiometricAvailable && !_biometricVerified)
                              ? 'Verify ${_biometricService.getBiometricTypeString()} first'
                              : 'Update Password',
                      onPressed: canSubmit ? _handleChangePassword : null,
                      isLoading: isLoading,
                      backgroundColor: (_isBiometricAvailable && !_biometricVerified)
                          ? Colors.grey.shade400
                          : AppColors.primary,
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
