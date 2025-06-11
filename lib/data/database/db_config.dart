import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBConfig {
  static Database? _database;
  static const String DB_NAME = 'clockin.db';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), DB_NAME);
    // When you change the schema (like adding columns), you should increment the version
    // and provide an onUpgrade callback for existing installations.
    // For simplicity in this example, we'll assume a fresh install or that
    // existing data can be dropped if the user is rebuilding the app.
    // In a real app, implement onUpgrade to preserve data.
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Create users table
    // ADDED: mobileNo, dob, bloodGroup, designation, joinedDate, profileImageUrl
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        email TEXT,
        password TEXT,
        role TEXT,
        mobileNo TEXT,
        dob TEXT,
        bloodGroup TEXT,
        designation TEXT,
        joinedDate TEXT,
        profileImageUrl TEXT
      )
    ''');

    // Create attendance table (unchanged)
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        date TEXT NOT NULL,
        timeIn TEXT,
        timeOut TEXT,
        workingHours TEXT,
        type TEXT,
        reason TEXT,
        status TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');
  }
}
