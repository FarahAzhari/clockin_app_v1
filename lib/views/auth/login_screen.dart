import 'package:clockin_app/controllers/auth_controller.dart';
import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/core/constants/app_text_styles.dart';
import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/routes/app_routes.dart';
import 'package:clockin_app/widgets/custom_input_field.dart';
import 'package:clockin_app/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authController = AuthController();

  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final isLoggedIn = await SessionManager().isLoggedIn();
    if (isLoggedIn) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final success = await _authController.login(email, password);

      if (success) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(Icons.lock, size: 100, color: AppColors.primary),
                ),
                const SizedBox(height: 20),
                const Text("Welcome Back", style: AppTextStyles.heading),
                const SizedBox(height: 10),
                const Text("Login to continue", style: AppTextStyles.normal),
                const SizedBox(height: 30),

                // Email
                CustomInputField(
                  controller: _emailController,
                  hintText: 'Email',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),

                // Password
                CustomInputField(
                  controller: _passwordController,
                  hintText: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  obscureText: !_isPasswordVisible,
                  toggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                const SizedBox(height: 30),

                // Login Button
                PrimaryButton(label: 'Login', onPressed: _login),
                const SizedBox(height: 20),

                // Go to register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.register),
                      child: const Text(
                        "Sign up",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
