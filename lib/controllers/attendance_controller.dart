// (optional) or you can use bloc/provider

import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/data/models/attendance_model.dart';
import 'package:clockin_app/data/services/attendance_service.dart';
import 'package:intl/intl.dart';

class AttendanceController {
  final AttendanceService _attendanceService = AttendanceService();

  Future<void> addAttendance({
    required String date,
    required String timeIn,
    required String timeOut,
    required String status,
  }) async {
    final attendance = AttendanceModel(
      date: date,
      timeIn: timeIn,
      timeOut: timeOut,
      status: status,
    );

    await _attendanceService.addAttendance(attendance);
  }

  Future<List<AttendanceModel>> getAllAttendance() async {
    return await _attendanceService.getAllAttendances();
  }

  Future<void> updateAttendance(int id, String status) async {
    final now = DateTime.now();
    final attendance = AttendanceModel(
      id: id,
      date: now.toIso8601String(),
      timeIn: '',
      timeOut: now.toIso8601String(),
      status: status,
    );
    await _attendanceService.updateAttendance(attendance);
  }

  Future<void> removeAttendance(int id) async {
    await _attendanceService.deleteAttendance(id);
  }

  Future<void> checkIn() async {
    final sessionManager = SessionManager();
    final userId = await sessionManager.getUserIdAsInt(); // get user ID

    if (userId == null) {
      throw Exception('User not logged in.');
    }

    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final timeIn = DateFormat('HH:mm:ss').format(now);

    // Define the threshold time (9:00 AM)
    final thresholdTime = DateTime(now.year, now.month, now.day, 9, 0, 0);

    // Compare current time with threshold
    final status = now.isAfter(thresholdTime) ? 'Late' : 'On Time';

    final attendance = AttendanceModel(
      userId: userId,
      date: today,
      timeIn: timeIn,
      timeOut: '',
      status: status,
    );

    await _attendanceService.addAttendance(attendance);
  }

  Future<void> checkOut() async {
    final sessionManager = SessionManager();
    final userId = await sessionManager.getUserIdAsInt(); // get user ID

    if (userId == null) {
      throw Exception('User not logged in.');
    }

    final now = DateTime.now();
    final userAttendances = await _attendanceService.getUserAttendances(userId);

    final latest = userAttendances.reversed.firstWhere(
      (a) => a.timeOut?.isEmpty ?? true,
      orElse: () => throw Exception('No check-in found'),
    );

    final updated = AttendanceModel(
      id: latest.id,
      userId: latest.userId,
      date: latest.date,
      timeIn: latest.timeIn,
      timeOut: DateFormat('HH:mm:ss').format(now),
      status: latest.status,
    );

    await _attendanceService.updateAttendance(updated);
  }
}
