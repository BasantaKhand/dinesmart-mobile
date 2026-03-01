import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/utils/snackbar_utils.dart';
import 'package:dinesmart_app/core/widgets/button_widget.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/change_password_page.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/signup_page.dart';
import 'package:dinesmart_app/features/auth/presentation/state/auth_state.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:dinesmart_app/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/pages/cashier_dashboard_page.dart';
import 'package:dinesmart_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/pages/waiter_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  void _navigateToSignUp() {
    AppRoutes.push(context, const SignupPage());
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      await ref
          .read(authViewModelProvider.notifier)
          .login(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
    final authState = ref.watch(authViewModelProvider);

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(context, 'Login successful! Welcome.');

        if (next.user?.role == 'WAITER') {
          AppRoutes.pushReplacement(context, const WaiterDashboardPage());
        } else if (next.user?.role == 'CASHIER') {
          AppRoutes.pushReplacement(context, const CashierDashboardPage());
        } else if (next.user?.role == 'RESTAURANT_ADMIN') {
          AppRoutes.pushReplacement(context, const AdminDashboardPage());
        } else {
          AppRoutes.pushReplacement(context, const DashboardPage());
        }
      } else if (next.status == AuthStatus.passwordChangeRequired) {
        AppRoutes.push(context, const ChangePasswordPage());
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/login_for.png',
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: _titleStyle,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Login to manage your restaurant dashboard.',
                    textAlign: TextAlign.center,
                    style: _subtitleStyle,
                  ),
                  const SizedBox(height: 22),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('Email'),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _fieldDecoration(
                            hint: 'Enter your email',
                          ),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'Please enter your email.';
                            if (!v.contains('@')) return 'Enter a valid email.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        _label('Password'),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleLogin(),
                          decoration: _fieldDecoration(
                            hint: 'Enter your password',
                            suffixIcon: IconButton(
                              onPressed: () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: AppColors.blackText.withAlpha(140),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password.';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? false),
                                activeColor: AppColors.primary,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                side: BorderSide(
                                  color: Colors.black.withAlpha(25),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Remember me',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blackText.withAlpha(160),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                overlayColor: AppColors.primary.withAlpha(10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                ),
                              ),
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        CustomButton(
                          text: authState.status == AuthStatus.loading
                              ? 'Logging in...'
                              : 'Login to DineSmart →',
                          onPressed: authState.status == AuthStatus.loading
                              ? null
                              : _handleLogin,
                          isLoading: authState.status == AuthStatus.loading,
                          backgroundColor: AppColors.primary,
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blackText.withAlpha(160),
                                ),
                              ),
                              GestureDetector(
                                onTap: _navigateToSignUp,
                                child: const Text(
                                  'Get started',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
