import 'dart:async';

import 'package:clockin_app/controllers/attendance_controller.dart';
import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/data/models/attendance_model.dart';
import 'package:clockin_app/data/services/attendance_service.dart';
import 'package:clockin_app/views/attendance/add_temporary.dart';
import 'package:flutter/material.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  final AttendanceController _attendanceController = AttendanceController();

  late Future<List<AttendanceModel>>? _attendanceFuture;

  late Timer _timer;

  // Flag to indicate if a deletion has occurred
  bool _hasDeleted = false;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = _attendanceController.getAllAttendance();
    _refreshList();
    _updateDateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateDateTime(),
    );
  }

  void _updateDateTime() {
    // This method seems to only trigger a setState,
    // which might not be necessary if time/date isn't displayed on this screen.
    // Keeping it as per your original code.
    setState(() {});
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
    _timer.cancel();
    // Removed Navigator.pop from dispose to prevent "deactivated widget" error.
    // The result will now be passed when the user explicitly taps the back button.
    super.dispose();
  }

  Widget _buildAttendanceTile(AttendanceModel attendance) {
    Color statusColor;
    // Determine color based on status or type
    if (attendance.status.toLowerCase() == 'late') {
      statusColor = Colors.red;
    } else if (attendance.status.toLowerCase() == 'on time') {
      statusColor = Colors.green;
    } else if (attendance.status.toLowerCase() == 'requested') {
      statusColor = const Color.fromARGB(
        255,
        228,
        205,
        4,
      ); // Color for requested items
    } else {
      statusColor = Colors.grey;
    }

    // Display for regular attendance records
    if (attendance.type == null) {
      return Card(
        color: AppColors.background,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: const Icon(Icons.access_time, color: AppColors.primary),
          title: Row(
            children: [
              Text(
                '${attendance.date} - ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                attendance.status,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          subtitle: Text(
            'In: ${attendance.timeIn ?? 'N/A'} | Out: ${attendance.timeOut ?? 'N/A'}',
          ),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: AppColors.error),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.background,
                  title: const Text('Delete Attendance'),
                  content: const Text(
                    'Are you sure you want to delete this attendance?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await _attendanceController.removeAttendance(attendance.id!);
                if (!mounted)
                  return; // Check if the widget is still in the tree
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attendance deleted')),
                );
                // Refresh list locally first
                await _refreshList();
                // Set the flag to true because a deletion occurred
                _hasDeleted = true;
              }
            },
          ),
        ),
      );
    } else {
      // Display for request records (only date and type/reason)
      return Card(
        color: AppColors.background,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          leading: const Icon(
            Icons.info,
            color: AppColors.primary,
          ), // Different icon for requests
          title: Row(
            // Wrap in a Row to apply color to the type
            children: [
              Text(
                '${attendance.date} - ',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                attendance.type ?? 'Request', // Show type
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ), // Apply color here
              ),
            ],
          ),
          subtitle: Text(
            'Reason: ${attendance.reason ?? 'N/A'}',
          ), // Show reason
          trailing: IconButton(
            icon: Icon(Icons.delete, color: AppColors.error),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.background,
                  title: const Text('Delete Request'),
                  content: const Text(
                    'Are you sure you want to delete this request?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await _attendanceController.removeAttendance(attendance.id!);
                if (!mounted)
                  return; // Check if the widget is still in the tree
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request deleted')),
                );
                // Refresh list locally first
                await _refreshList();
                // Set the flag to true because a deletion occurred
                _hasDeleted = true;
              }
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance List'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        // Set automaticallyImplyLeading to false to use a custom leading button
        automaticallyImplyLeading: false,
        leading: IconButton(
          // Custom back button
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Pop with the _hasDeleted flag as result
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
              // If AddTemporary returned true (indicating a successful add), refresh the list
              if (result == true) {
                _refreshList();
                // If a temporary attendance was added, it might affect today's record status
                // so we also set _hasDeleted to true to trigger a refresh in MainScreen
                _hasDeleted = true;
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
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

            return Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.only(
                    bottom: 100,
                  ), // Add padding for the button
                  children: [
                    if (attendances.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text('No attendance records found.'),
                        ),
                      )
                    else
                      ...attendances.map(_buildAttendanceTile),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
