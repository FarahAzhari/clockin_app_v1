import 'dart:async';

import 'package:clockin_app/controllers/attendance_controller.dart'; // Actual AttendanceController
// Importing actual classes from your project structure
import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/data/local_storage/session_manager.dart'; // Actual SessionManager
import 'package:clockin_app/data/models/attendance_model.dart';
import 'package:clockin_app/data/services/attendance_service.dart'; // Actual AttendanceService
import 'package:clockin_app/routes/app_routes.dart';
import 'package:clockin_app/views/attendance/request_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Use actual controllers and services
  final SessionManager _sessionManager = SessionManager();
  final AttendanceController _attendanceController = AttendanceController();
  final AttendanceService _attendanceService =
      AttendanceService(); // Used for _fetchTodayAttendance logic

  String _userName = 'User';
  String _location = 'Loading Location...'; // Will be set to a static value
  String _currentDate = '';
  String _currentTime = '';
  Timer? _timer;
  AttendanceModel? _todayRecord;

  // Placeholder for attendance summary counts (these would typically come from a service)
  final int _presentCount = 13;
  final int _absentCount = 2;
  final int _lateInCount = 4;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _updateDateTime();
    _fetchTodayAttendance(); // Initial fetch
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateDateTime(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    // Use getUsername from the provided SessionManager
    final userName = await _sessionManager.getUsername();
    setState(() {
      _userName = userName ?? 'User'; // Default if null
      // Set location statically as SessionManager does not provide it
      _location = 'PPKD Jakarta Pusat';
    });
  }

  void _updateDateTime() {
    final now = DateTime.now();
    setState(() {
      _currentDate = DateFormat('yyyy-MM-dd').format(now);
      _currentTime = DateFormat('HH:mm:ss a').format(now);
    });
  }

  Future<void> _fetchTodayAttendance() async {
    final userId = await _sessionManager.getUserIdAsInt();

    if (userId == null) {
      print('Error: User ID is null. Cannot fetch attendance for today.');
      setState(() {
        _todayRecord = AttendanceModel(
          userId: 0,
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          status: 'Not Logged In',
        );
      });
      return;
    }

    try {
      final allAttendances = await _attendanceService.getUserAttendances(
        userId,
      );
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final todayRecord = allAttendances.firstWhere(
        (a) => a.date == today && a.type == null, // Only regular attendance
        orElse: () => AttendanceModel(
          userId: userId,
          date: today,
          timeIn: null,
          timeOut: null,
          status: 'No Record Today',
        ),
      );

      setState(() {
        _todayRecord = todayRecord;
        // Optionally update summary counts here if you have methods for them
        // For now, keeping them static as per original code structure
      });
    } catch (e) {
      print('Error fetching today\'s attendance: $e');
      setState(() {
        _todayRecord = AttendanceModel(
          userId: userId,
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          status: 'Error fetching data',
        );
      });
    }
  }

  Future<void> _handleCheckIn() async {
    try {
      await _attendanceController.checkIn();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Checked in successfully!')));
      _fetchTodayAttendance(); // Refresh status after check-in
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Check-in failed: $e')));
    }
  }

  Future<void> _handleCheckOut() async {
    try {
      await _attendanceController.checkOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checked out successfully!')),
      );
      _fetchTodayAttendance(); // Refresh status after check-out
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Check Out Failed'),
          content: Text('$e'), // Display the actual error message
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if timeIn is null or empty to determine check-in status
    final bool hasCheckedIn =
        _todayRecord != null &&
        (_todayRecord!.timeIn != null && _todayRecord!.timeIn!.isNotEmpty);
    // Check if timeOut is null or empty to determine check-out status
    final bool hasCheckedOut =
        _todayRecord != null &&
        (_todayRecord!.timeOut != null && _todayRecord!.timeOut!.isNotEmpty);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 80, // Increased height for better spacing
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        _location,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    // Handle notification button press
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background wave/curve if desired
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120, // Height of the blue background
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
            ),
          ),
          ListView(
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 80,
            ), // Adjust padding for app bar and bottom nav
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Text(
                  'Welcome, $_userName',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Welcome text on blue background
                  ),
                ),
              ),
              const SizedBox(height: 20), // Space between welcome and cards
              _buildMainActionCard(hasCheckedIn, hasCheckedOut),
              const SizedBox(height: 20),
              _buildAttendanceSummary(),
            ],
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RequestScreen()),
                  );
                  if (result == true) {
                    _fetchTodayAttendance(); // Refresh data if a request was made
                  }
                },
                icon: const Icon(Icons.add_task, color: AppColors.primary),
                label: const Text(
                  'Request',
                  style: TextStyle(color: AppColors.primary, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // Set the current index for 'Home'
        onTap: (index) async {
          // Handle navigation using named routes
          // Handle navigation using named routes
          if (index == 0) {
            // Already on home screen, do nothing or pop to root
            // if you have multiple nested navigators.
            // For now, no action needed for current index.
          } else if (index == 1) {
            // Navigate to AttendanceListScreen and await result
            final result = await Navigator.pushNamed(
              context,
              AppRoutes.attendanceList,
            );
            if (result == true) {
              // If result is true, it means a deletion occurred, so refetch data
              _fetchTodayAttendance();
            }
          } else if (index == 2) {
            Navigator.pushNamed(context, AppRoutes.report);
          } else if (index == 3) {
            Navigator.pushNamed(context, AppRoutes.profile);
          }
          // You can add more navigation logic here for other tabs
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
      ),
    );
  }

  Widget _buildMainActionCard(bool hasCheckedIn, bool hasCheckedOut) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Handle Home button press
                    },
                    icon: const Icon(Icons.home, color: AppColors.primary),
                    label: const Text(
                      'Home',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Handle Office button press
                    },
                    icon: const Icon(Icons.business, color: Colors.grey),
                    label: const Text(
                      'Office',
                      style: TextStyle(color: Colors.grey),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'GENERAL SHIFT',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentTime,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      _currentDate,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: hasCheckedIn
                      ? (hasCheckedOut ? null : _handleCheckOut)
                      : _handleCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasCheckedIn
                        ? (hasCheckedOut ? Colors.grey : Colors.redAccent)
                        : AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    hasCheckedIn
                        ? (hasCheckedOut ? 'Checked Out' : 'Check Out')
                        : 'Check In',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeDetail(
                  Icons.watch_later_outlined,
                  _todayRecord?.timeIn ?? 'N/A', // Use N/A if null
                  'Check In',
                  AppColors.primary,
                ),
                _buildTimeDetail(
                  Icons.watch_later_outlined,
                  _todayRecord?.timeOut ?? 'N/A', // Use N/A if null
                  'Check Out',
                  Colors.redAccent,
                ),
                _buildTimeDetail(
                  Icons.watch_later_outlined,
                  _calculateWorkingHours(),
                  'Working HR\'s',
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDetail(
    IconData icon,
    String time,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 5),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textLight),
        ),
      ],
    );
  }

  String _calculateWorkingHours() {
    // Use the actual _todayRecord for calculation
    if (_todayRecord == null ||
        _todayRecord!.timeIn == null ||
        _todayRecord!.timeIn!.isEmpty) {
      return '00:00:00'; // No check-in yet
    }

    try {
      final now = DateTime.now();
      final checkInTimeParts = _todayRecord!.timeIn!.split(':');
      final checkInHour = int.parse(checkInTimeParts[0]);
      final checkInMinute = int.parse(checkInTimeParts[1]);
      final checkInSecond = int.parse(checkInTimeParts[2]);

      // Create DateTime object for check-in on today's date
      final checkInDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        checkInHour,
        checkInMinute,
        checkInSecond,
      );

      DateTime endDateTime;
      if (_todayRecord!.timeOut != null && _todayRecord!.timeOut!.isNotEmpty) {
        final checkOutTimeParts = _todayRecord!.timeOut!.split(':');
        final checkOutHour = int.parse(checkOutTimeParts[0]);
        final checkOutMinute = int.parse(checkOutTimeParts[1]);
        final checkOutSecond = int.parse(checkOutTimeParts[2]);
        // Create DateTime object for check-out on today's date
        endDateTime = DateTime(
          now.year,
          now.month,
          now.day,
          checkOutHour,
          checkOutMinute,
          checkOutSecond,
        );
      } else {
        endDateTime = now; // If not checked out, use current time
      }

      final Duration duration = endDateTime.difference(checkInDateTime);
      final int hours = duration.inHours;
      final int minutes = duration.inMinutes.remainder(60);
      final int seconds = duration.inSeconds.remainder(60);

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Error calculating working hours: $e');
      return '00:00:00';
    }
  }

  Widget _buildAttendanceSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attendance for this Month',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      DateFormat('MMM').format(DateTime.now()).toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildSummaryCard('Present', _presentCount, Colors.green),
              const SizedBox(width: 10),
              _buildSummaryCard('Absents', _absentCount, Colors.red),
              const SizedBox(width: 10),
              _buildSummaryCard('Late in', _lateInCount, Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                count.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
