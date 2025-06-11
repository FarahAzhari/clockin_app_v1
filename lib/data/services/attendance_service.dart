import 'package:clockin_app/data/database/db_config.dart';
import 'package:clockin_app/data/models/attendance_model.dart';
import 'package:sqflite/sqflite.dart';

class AttendanceService {
  Future<int> addAttendance(AttendanceModel attendance) async {
    final db = await DBConfig.database;
    return await db.insert(
      'attendance',
      attendance.toMap(), // .toMap() should now include 'workingHours'
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AttendanceModel>> getAllAttendances() async {
    final db = await DBConfig.database;
    final List<Map<String, dynamic>> maps = await db.query('attendance');
    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(
        maps[i],
      ); // .fromMap() should now read 'workingHours'
    });
  }

  Future<List<AttendanceModel>> getUserAttendances(int userId) async {
    final db = await DBConfig.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, timeIn DESC', // Order to get latest first
    );
    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(
        maps[i],
      ); // .fromMap() should now read 'workingHours'
    });
  }

  // NEW METHOD: Get attendance by ID
  Future<AttendanceModel?> getAttendanceById(int id) async {
    final db = await DBConfig.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return AttendanceModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateAttendance(AttendanceModel attendance) async {
    final db = await DBConfig.database;
    return await db.update(
      'attendance',
      attendance.toMap(), // .toMap() should now include 'workingHours'
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await DBConfig.database;
    return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }

  // New method to insert a request (unchanged, but implicitly uses updated AttendanceModel)
  Future<int> insertRequest(AttendanceModel request) async {
    final db = await DBConfig.database;
    return await db.insert(
      'attendance',
      request.toMap(), // .toMap() should now include 'workingHours'
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
