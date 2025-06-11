import 'dart:async';

import 'package:clockin_app/controllers/attendance_controller.dart';
import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/data/models/attendance_model.dart'; // IMPORTANT: Ensure workingHours is added here
import 'package:clockin_app/data/services/attendance_service.dart';
import 'package:clockin_app/views/attendance/add_temporary.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// IMPORTANT: Please ensure your 'clockin_app/core/constants/app_colors.dart'
// file defines the following colors. If not, add them:
// class AppColors {
//   static const Color primary = Color(0xFF4A90E2); // Example primary color
//   static const Color background = Color(0xFFF0F2F5); // Example light background
//   static const Color error = Color(0xFFD0021B); // Example error color
//
//   // Accent colors for status/types
//   static const Color accentGreen = Colors.green; // For 'On Time' / 'Present'
//   static const Color accentRed = Colors.red; // For 'Late' / specific 'Absent'
//   static const Color accentOrange = Colors.orange; // For 'Leave' / 'Sick' / other requests
//
//   // Light background colors for cards based on type
//   static const Color lightGreenBackground = Color(0xFFE8F5E9); // Light green for present
//   static const Color lightRedBackground = Color(0xFFFFEBEE); // Light red for absent
//   static const Color lightOrangeBackground = Color(0xFFFFF3E0); // Light orange for requests
//   // Define other colors used in your app like textDark, textLight, inputFill etc.
//   static const Color textDark = Color(0xFF333333);
//   static const Color textLight = Color(0xFF666666);
//   static const Color inputFill = Color(0xFFFFFFFF);
// }

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  final AttendanceController _attendanceController = AttendanceController();
  late Future<List<AttendanceModel>>? _attendanceFuture;
  bool _hasDeleted = false;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = _attendanceController.getAllAttendance();
    _refreshList();
  }

  Future<void> _refreshList() async {
    final userId = await SessionManager().getUserIdAsInt();

    if (userId == null) {
      setState(() {
        _attendanceFuture = Future.value([]);
      });
      print('Error: User ID is null. Cannot fetch attendance.');
      return;
    }

    final all = await AttendanceService().getUserAttendances(userId);

    setState(() {
      _attendanceFuture = Future.value(all);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildAttendanceTile(AttendanceModel attendance) {
    Color barColor;
    Color statusPillColor;
    Color cardBackgroundColor = AppColors.background;
    Color timeTextColor;

    bool isRequestType = attendance.type != null;

    if (isRequestType) {
      barColor = AppColors.accentOrange;
      statusPillColor = AppColors.accentOrange;
      cardBackgroundColor = AppColors.lightOrangeBackground;
      timeTextColor = Colors
          .black; // Not directly used for request types, but kept for consistency
    } else {
      if (attendance.status.toLowerCase() == 'late') {
        barColor = AppColors.accentRed;
        statusPillColor = AppColors.accentRed;
        timeTextColor = AppColors.accentRed; // Time text is red for 'late'
      } else {
        barColor = AppColors.accentGreen;
        statusPillColor = AppColors.accentGreen;
        timeTextColor =
            AppColors.accentGreen; // Time text is green for 'on time'
      }
      // cardBackgroundColor remains AppColors.background for regular types
    }

    bool showHouseIcon =
        attendance.type == null && attendance.status.toLowerCase() == 'on time';

    final DateTime date = DateTime.parse(attendance.date);
    final String formattedDate = DateFormat('E, MMM d, yyyy').format(date);

    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5.0,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isRequestType
                                ? statusPillColor
                                : statusPillColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              if (showHouseIcon)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4.0),
                                  child: Icon(
                                    Icons.house,
                                    size: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              Text(
                                isRequestType
                                    ? attendance.type!
                                    : (attendance.status.toLowerCase() ==
                                              'on time'
                                          ? 'GENERAL'
                                          : attendance.status.toUpperCase()),
                                style: TextStyle(
                                  color: isRequestType
                                      ? Colors.white
                                      : Colors.black54,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!isRequestType)
                      Row(
                        children: [
                          _buildTimeColumn(
                            attendance.timeIn ?? 'N/A',
                            'Check In',
                            timeTextColor,
                          ),
                          const SizedBox(width: 20),
                          _buildTimeColumn(
                            attendance.timeOut ?? 'N/A',
                            'Check Out',
                            timeTextColor,
                          ),
                          const SizedBox(
                            width: 20,
                          ), // Added space for working hours
                          _buildTimeColumn(
                            // Display working hours from the model
                            attendance.workingHours ?? '00:00:00',
                            'Working HR\'s',
                            timeTextColor, // Use same color as other times
                          ),
                        ],
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Reason: ${attendance.reason ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.grey.withOpacity(0.7)),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.background,
                      title: const Text('Cancel Entry'),
                      content: const Text(
                        'Are you sure you want to cancel this entry?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'No',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            'Yes',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    await _attendanceController.removeAttendance(
                      attendance.id!,
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Entry cancelled')),
                    );
                    await _refreshList();
                    _hasDeleted = true;
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(String time, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context, _hasDeleted);
          },
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddTemporary()),
              );
              if (result == true) {
                _refreshList();
                _hasDeleted = true;
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Monthly',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(30),
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
                      SizedBox(width: 5),
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
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshList,
              child: FutureBuilder<List<AttendanceModel>>(
                future: _attendanceFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final attendances = snapshot.data ?? [];

                  if (attendances.isEmpty) {
                    return const Center(
                      child: Text('No attendance records found.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: attendances.length,
                    itemBuilder: (context, index) {
                      return _buildAttendanceTile(attendances[index]);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
