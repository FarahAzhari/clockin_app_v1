import 'dart:async';

import 'package:clockin_app/controllers/attendance_controller.dart';
import 'package:clockin_app/core/constants/app_colors.dart';
import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/data/models/attendance_model.dart';
import 'package:clockin_app/data/services/attendance_service.dart';
import 'package:clockin_app/views/attendance/add_temporary.dart';
import 'package:clockin_app/views/attendance/request_screen.dart'; // Import the new RequestScreen
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  final AttendanceController _attendanceController = AttendanceController();

  late Future<List<AttendanceModel>>? _attendanceFuture;
  AttendanceModel? _todayRecord;

  late String _currentDate;
  late String _currentTime;
  late Timer _timer;

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
    final now = DateTime.now();
    setState(() {
      _currentDate = DateFormat('yyyy-MM-dd').format(now);
      _currentTime = DateFormat('HH:mm:ss').format(now);
    });
  }

  Future<void> _refreshList() async {
    final userId = await SessionManager().getUserIdAsInt();

    if (userId == null) {
      setState(() {
        _attendanceFuture = Future.value([]);
        _todayRecord = AttendanceModel(
          userId: 0,
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          status: 'Not Logged In',
        );
      });
      print('Error: User ID is null. Cannot fetch attendance.');
      return;
    }

    final all = await AttendanceService().getUserAttendances(userId);

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayRecord = all.firstWhere(
      (a) =>
          a.date == today &&
          a.type == null, // Only consider regular attendance for today's record
      orElse: () => AttendanceModel(
        userId: userId,
        date: today,
        timeIn: null, // Ensure timeIn is null for "No Record Today"
        timeOut: null, // Ensure timeOut is null for "No Record Today"
        status: 'No Record Today',
      ),
    );

    setState(() {
      _attendanceFuture = Future.value(all);
      _todayRecord = todayRecord;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
      statusColor = Colors.deepOrangeAccent; // Color for requested items
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Attendance deleted')),
                );
                _refreshList();
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Request deleted')),
                );
                _refreshList();
              }
            },
          ),
        ),
      );
    }
  }

  TextStyle _labelStyle() => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  Widget _buildActionCard() {
    final hasCheckedIn =
        _todayRecord != null &&
        _todayRecord!.timeIn != null &&
        _todayRecord!.timeIn!.isNotEmpty;
    final hasCheckedOut =
        _todayRecord != null && (_todayRecord!.timeOut?.isNotEmpty ?? false);

    return Card(
      color: AppColors.background,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date: $_currentDate", style: _labelStyle()),
            const SizedBox(height: 4),
            Text("Time: $_currentTime", style: _labelStyle()),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: hasCheckedIn
                        ? null
                        : () async {
                            await _attendanceController.checkIn();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Checked in successfully!'),
                              ),
                            );
                            _refreshList();
                          },
                    icon: const Icon(Icons.login, color: AppColors.inputFill),
                    label: const Text(
                      'Check In',
                      style: TextStyle(color: AppColors.inputFill),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !hasCheckedIn
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: AppColors.background,
                                title: const Text('Check Out Failed'),
                                content: const Text(
                                  'You must check in before checking out.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        : hasCheckedOut
                        ? null
                        : () async {
                            await _attendanceController.checkOut();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Checked out successfully!'),
                              ),
                            );
                            _refreshList();
                          },
                    icon: const Icon(Icons.logout, color: AppColors.inputFill),
                    label: const Text(
                      'Check Out',
                      style: TextStyle(color: AppColors.inputFill),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      disabledBackgroundColor: Colors.grey,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance List'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddTemporary(),
                ), // It's fine to use const if AddTemporary is stateless, but remove if it has state. I put const here assuming it was added in the previous step. If it still causes an error, remove it.
              );
              // If AddTemporary returned true (indicating a successful add), refresh the list
              if (result == true) {
                _refreshList();
              }
            },
            icon: const Icon(Icons.add), // Add const here too for efficiency
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
                    _buildActionCard(),
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
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RequestScreen(),
                          ),
                        );
                        if (result == true) {
                          _refreshList();
                        }
                      },
                      icon: const Icon(
                        Icons.add_task,
                        color: AppColors.inputFill,
                      ),
                      label: const Text(
                        'Request',
                        style: TextStyle(
                          color: AppColors.inputFill,
                          fontSize: 18,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
