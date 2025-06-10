import 'package:clockin_app/data/database/db_config.dart';
import 'package:clockin_app/data/models/attendance_model.dart';
import 'package:sqflite/sqflite.dart';

class AttendanceService {
  Future<int> addAttendance(AttendanceModel attendance) async {
    final db = await DBConfig.database;
    return await db.insert(
      'attendance',
      attendance.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AttendanceModel>> getAllAttendances() async {
    final db = await DBConfig.database;
    final List<Map<String, dynamic>> maps = await db.query('attendance');
    return List.generate(maps.length, (i) {
      return AttendanceModel.fromMap(maps[i]);
    });
  }

  Future<int> updateAttendance(AttendanceModel attendance) async {
    final db = await DBConfig.database;
    return await db.update(
      'attendance',
      attendance.toMap(),
      where: 'id = ?',
      whereArgs: [attendance.id],
    );
  }

  Future<int> deleteAttendance(int id) async {
    final db = await DBConfig.database;
    return await db.delete('attendance', where: 'id = ?', whereArgs: [id]);
  }
}
