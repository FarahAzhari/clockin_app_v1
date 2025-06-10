import 'dart:async';

import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/core/constants/app_text_styles.dart';
import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/routes/app_routes.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    await Future.delayed(const Duration(seconds: 3));

    final isLoggedIn = await SessionManager().isLoggedIn();
    final nextRoute = isLoggedIn ? AppRoutes.main : AppRoutes.login;

    if (!mounted) return;

    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.access_alarm, size: 90, color: AppColors.primary),
              SizedBox(height: 20),
              Text('ClockIn', style: AppTextStyles.heading),
              SizedBox(height: 10),
              Text(
                'Welcome to the future of attendance!',
                textAlign: TextAlign.center,
                style: AppTextStyles.normal,
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
