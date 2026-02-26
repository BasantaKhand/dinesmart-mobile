

import 'package:dinesmart_app/app/routes/app_routes.dart';
import 'package:dinesmart_app/app/theme/app_colors.dart';
import 'package:dinesmart_app/core/utils/snackbar_utils.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/signup_page.dart';
import 'package:dinesmart_app/features/auth/presentation/state/auth_state.dart';
import 'package:dinesmart_app/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:dinesmart_app/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:dinesmart_app/features/waiter_dashboard/presentation/pages/waiter_dashboard_page.dart';
import 'package:dinesmart_app/features/cashier_dashboard/presentation/pages/cashier_dashboard_page.dart';
import 'package:dinesmart_app/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart';
import 'package:dinesmart_app/features/auth/presentation/pages/change_password_page.dart';
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

  @override
  void initState(){
    super.initState();
  }


  //navigate to signup page 
  void _navigateToSignUp(){
    AppRoutes.push(context, SignupPage());
  }



    Future<void> _handleLogin() async {
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
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
        // Listen to auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(
          context,
          'login successful! welcome.',
        );
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
      backgroundColor: AppColors.backgroundPrimary,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(2),
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 2,
                  color: Colors.white,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/login_for.png',
                      height: 350,
                      width: 350,
                      fit: BoxFit.fill,
                    ),
                    Text(
                      'login',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Divider(
                          height: 3,
                          color: AppColors.primary,
                          indent: 120,
                          endIndent: 120,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 50),

            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        fillColor: AppColors.backgroundPrimary,
                        labelText: 'Email address',
                        hintText: 'please enter your email',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black26,
                            width: 2,
                            ),
                          ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black26,
                            width: 2,
                            ),
                          ),
                        ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'please enter valid password';
                        }
                        return null;
                      }
                   ),

                    const SizedBox(height: 10),

                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        fillColor: AppColors.backgroundPrimary,
                        labelText: 'Password',
                        hintText: 'please enter your password',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black26,
                            width: 2,
                            ),
                          ),
                        errorBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black26,
                            width: 2,
                            ),
                          ),
                        ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return 'please enter valid email';
                        }
                        return null;
                      }
                    ),


                    // 🔹 FORGOT PASSWORD (INSIDE FORM, RIGHT SIDE)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                         
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _handleLogin();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(  
                            borderRadius: BorderRadius.circular(25)
                          )
                        ),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have account yet?",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _navigateToSignUp();
                  },
                  child: const Text(
                    'contact for signup',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            
          ],
        ),
      ),
    );
  }
}
