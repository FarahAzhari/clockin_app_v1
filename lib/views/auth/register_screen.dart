import 'package:flutter/material.dart';
import 'package:clockin_app/controllers/auth_controller.dart';
import 'package:clockin_app/data/models/user_model.dart';
import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/core/constants/app_text_styles.dart';
import 'package:clockin_app/widgets/primary_button.dart';
import 'package:clockin_app/widgets/custom_input_field.dart';
import 'package:clockin_app/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authController = AuthController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final user = UserModel(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: 'user',
      );

      final success = await _authController.register(user);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful!")),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Registration failed!")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create Account",
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.primary,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Join us to track your attendance effortlessly.",
                      style: AppTextStyles.normal.copyWith(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Username
                    CustomInputField(
                      controller: _usernameController,
                      hintText: "Username",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    CustomInputField(
                      controller: _emailController,
                      hintText: "Email",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Password
                    CustomInputField(
                      controller: _passwordController,
                      hintText: "Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: !_isPasswordVisible,
                      toggleVisibility: () => setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      }),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password
                    CustomInputField(
                      controller: _confirmPasswordController,
                      hintText: "Confirm Password",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: !_isConfirmPasswordVisible,
                      toggleVisibility: () => setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      }),
                    ),
                    const SizedBox(height: 32),

                    PrimaryButton(label: "Register", onPressed: _register),
                    const SizedBox(height: 20),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
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
            ),
          ),
        ),
      ),
    );
  }
}
