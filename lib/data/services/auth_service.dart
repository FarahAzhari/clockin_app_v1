// auth_service.dart
import 'package:sqflite/sqflite.dart'; // Import sqflite for Database type

import '../database/db_config.dart';
import '../models/user_model.dart'; // Ensure this import points to your UserModel

class AuthService {
  static const String TABLE_USERS = 'users';

  // Fetches a user by email and password for login
  Future<UserModel?> login(String email, String password) async {
    final db = await DBConfig.database;
    final List<Map<String, dynamic>> result = await db.query(
      TABLE_USERS,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1, // Limit to one result for unique login
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  // Registers a new user with all available details
  Future<int> register(UserModel user) async {
    final db = await DBConfig.database;
    // Ensure the toMap() method in UserModel correctly handles all fields
    return await db.insert(
      TABLE_USERS,
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // NEW METHOD: Fetches a user by ID
  Future<UserModel?> getUserById(int userId) async {
    final db = await DBConfig.database;
    final List<Map<String, dynamic>> result = await db.query(
      TABLE_USERS,
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1, // Expecting only one user per ID
    );
    if (result.isNotEmpty) {
      return UserModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await DBConfig.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return UserModel.fromMap(maps[i]);
    });
  }

  // Optional: Update user profile details
  Future<int> updateUserDetails(UserModel user) async {
    final db = await DBConfig.database;
    // Update all fields except ID which is used for where clause
    return await db.update(
      TABLE_USERS,
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
