import 'package:clockin_app/data/models/attendance_model.dart';
import 'package:clockin_app/data/models/user_model.dart';
import 'package:clockin_app/data/services/attendance_service.dart';
import 'package:clockin_app/data/services/auth_service.dart';
import 'package:flutter/material.dart';

class PersonReportScreen extends StatefulWidget {
  const PersonReportScreen({super.key});

  @override
  State<PersonReportScreen> createState() => _PersonReportScreenState();
}

class _PersonReportScreenState extends State<PersonReportScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final AuthService _userService =
      AuthService(); // Assuming you have a user service

  List<UserModel> _users = [];
  List<AttendanceModel> _attendanceList = [];

  int? _selectedUserId; // Track the selected user

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Load all users (You can modify this to only load active users or users you want)
  Future<void> _loadUsers() async {
    final users = await _userService.getAllUsers();
    setState(() {
      _users = users;
    });
  }

  // Fetch attendance for selected user
  Future<void> _loadAttendanceForUser(int userId) async {
    final attendance = await _attendanceService.getUserAttendances(userId);
    setState(() {
      _attendanceList = attendance;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Report')),
      body: Column(
        children: [
          // Dropdown or list to select user
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<int>(
              hint: const Text("Select User"),
              value: _selectedUserId,
              onChanged: (value) {
                setState(() {
                  _selectedUserId = value;
                  _loadAttendanceForUser(
                    value!,
                  ); // Load attendance when user is selected
                });
              },
              items: _users.map((user) {
                return DropdownMenuItem<int>(
                  value: user.id,
                  child: Text(user.username), // Display user name
                );
              }).toList(),
            ),
          ),

          // Display attendance records
          Expanded(
            child: _attendanceList.isEmpty
                ? const Center(child: Text("No attendance records available."))
                : ListView.builder(
                    itemCount: _attendanceList.length,
                    itemBuilder: (context, index) {
                      final attendance = _attendanceList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.access_time),
                          title: Text(
                            '${attendance.date} - ${attendance.status}',
                          ),
                          subtitle: Text(
                            'In: ${attendance.timeIn} | Out: ${attendance.timeOut}',
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
