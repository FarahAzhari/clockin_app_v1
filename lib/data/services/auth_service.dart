// auth_service.dart

import '../models/user_model.dart';
import '../database/db_config.dart';

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
}
