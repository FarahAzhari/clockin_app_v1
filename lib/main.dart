import 'package:clockin_app/routes/app_routes.dart';
import 'package:clockin_app/views/attendance/request_screen.dart';
import 'package:clockin_app/views/auth/login_screen.dart';
import 'package:clockin_app/views/auth/register_screen.dart';
import 'package:clockin_app/views/auth/splash_screen.dart';
import 'package:clockin_app/views/main_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClockIn',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.main: (context) => MainBottomNavigationBar(),
        AppRoutes.request: (context) => RequestScreen(),
        // AppRoutes.attendanceList: (context) => AttendanceListScreen(),
        // AppRoutes.report: (context) => const PersonReportScreen(),
        // AppRoutes.profile: (context) => const ProfileScreen(),
      },
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: SplashScreen(),
    );
  }
}
