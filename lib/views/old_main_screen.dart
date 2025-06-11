import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/views/attendance/attendance_list_screen.dart';
import 'package:clockin_app/views/profile/profile_screen.dart';
import 'package:clockin_app/views/reports/person_report_screen.dart';
import 'package:flutter/material.dart';

class OldMainScreen extends StatefulWidget {
  final int initialTab;

  const OldMainScreen({super.key, this.initialTab = 0}); // Default to tab 0

  @override
  State<OldMainScreen> createState() => _OldMainScreenState();
}

class _OldMainScreenState extends State<OldMainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
  }

  final List<Widget> _screens = [
    AttendanceListScreen(),
    PersonReportScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_rounded),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Report',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
