// auth_service.dart

import '../database/db_config.dart';
import '../models/user_model.dart';

class AuthService {
  static const String TABLE_USERS = 'users';

  Future<UserModel?> login(String email, String password) async {
    final db = await DBConfig.database;
    final result = await db.query(
      TABLE_USERS,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> register(UserModel user) async {
    final db = await DBConfig.database;
    return await db.insert(TABLE_USERS, user.toMap());
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await DBConfig.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return UserModel.fromMap(maps[i]);
    });
  }
}
