import 'package:clockin_app/data/local_storage/session_manager.dart';
import 'package:clockin_app/data/models/attendance_model.dart';
import 'package:clockin_app/data/services/attendance_service.dart';
import 'package:intl/intl.dart';

class AttendanceController {
  final AttendanceService _attendanceService = AttendanceService();

  Future<void> addAttendance({
    required int userId,
    required String date,
    required String timeIn,
    required String timeOut,
    required String status,
    String? type, // Keep this for requests
    String? reason, // Keep this for requests
    String? workingHours, // Accepts workingHours
  }) async {
    final attendance = AttendanceModel(
      userId: userId,
      date: date,
      timeIn: timeIn,
      timeOut: timeOut,
      status: status,
      type: type,
      reason: reason,
      workingHours: workingHours, // Pass workingHours to model
    );

    await _attendanceService.addAttendance(attendance);
  }

  Future<List<AttendanceModel>> getAllAttendance() async {
    return await _attendanceService.getAllAttendances();
  }

  Future<void> updateAttendance(int id, int userId, String status) async {
    // Fetch the existing record to preserve all other fields
    final existingRecord = await _attendanceService.getAttendanceById(id);
    if (existingRecord == null) {
      throw Exception('Attendance record with ID $id not found for update.');
    }

    // Manually create a new AttendanceModel instance with updated status
    // and copy all other fields from the existing record.
    final updated = AttendanceModel(
      id: existingRecord.id,
      userId: existingRecord.userId,
      date: existingRecord.date,
      timeIn: existingRecord.timeIn,
      timeOut: existingRecord.timeOut,
      status: status, // Update status
      type: existingRecord.type,
      reason: existingRecord.reason,
      workingHours: existingRecord.workingHours, // Preserve workingHours
    );

    await _attendanceService.updateAttendance(updated);
  }

  Future<void> removeAttendance(int id) async {
    await _attendanceService.deleteAttendance(id);
  }

  Future<void> checkIn() async {
    final sessionManager = SessionManager();
    final userId = await sessionManager.getUserIdAsInt();

    if (userId == null) {
      throw Exception('User not logged in.');
    }

    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final timeIn = DateFormat('HH:mm:ss').format(now);

    final thresholdTime = DateTime(now.year, now.month, now.day, 9, 0, 0);
    final status = now.isAfter(thresholdTime) ? 'Late' : 'On Time';

    final attendance = AttendanceModel(
      userId: userId,
      date: today,
      timeIn: timeIn,
      timeOut: '',
      status: status,
      workingHours: null, // Initialized as null at check-in
    );

    await _attendanceService.addAttendance(attendance);
  }

  Future<void> checkOut({String? workingHours}) async {
    final sessionManager = SessionManager();
    final userId = await sessionManager.getUserIdAsInt();

    if (userId == null) {
      throw Exception('User not logged in.');
    }

    final now = DateTime.now();
    final userAttendances = await _attendanceService.getUserAttendances(userId);
    final today = DateFormat('yyyy-MM-dd').format(now);

    // Find the latest check-in record for today that has not been checked out yet
    final latestUncheckedOutRecord = userAttendances.firstWhere(
      (a) => a.date == today && (a.timeOut?.isEmpty ?? true) && a.type == null,
      orElse: () => throw Exception(
        'No active check-in record found for today to check out.',
      ),
    );

    // Manually create a new AttendanceModel instance with updated timeOut and workingHours
    // and copy all other fields from the latestUncheckedOutRecord.
    final updated = AttendanceModel(
      id: latestUncheckedOutRecord.id,
      userId: latestUncheckedOutRecord.userId,
      date: latestUncheckedOutRecord.date,
      timeIn: latestUncheckedOutRecord.timeIn,
      timeOut: DateFormat('HH:mm:ss').format(now), // Set check-out time
      status: latestUncheckedOutRecord.status, // Preserve original status
      type: latestUncheckedOutRecord.type, // Preserve type
      reason: latestUncheckedOutRecord.reason, // Preserve reason
      workingHours: workingHours, // Pass the calculated working hours
    );

    await _attendanceService.updateAttendance(updated);
  }

  Future<void> insertRequest(AttendanceModel request) async {
    await _attendanceService.insertRequest(request);
  }
}
